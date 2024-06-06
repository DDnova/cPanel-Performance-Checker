#!/bin/bash

# Author: Darryl Dsouza
# Date: 2024-05-29
# License: MIT License

# Function to check CPU load and compare with number of cores
check_cpu_load() {
    echo "------------------------------------"
    echo "Checking CPU Load"
    echo "------------------------------------"
    load=$(uptime | awk -F'[a-z]:' '{ print $2 }')
    echo "Current load averages:$load"

    nproc_value=$(nproc)
    load_1=$(uptime | awk -F'[a-z]:' '{ print $2 }' | awk '{print $1}' | sed 's/,//')
    if (( $(echo "$load_1 > $nproc_value" | bc -l) )); then
        echo -e "\033[1;33mSuggestion:\033[0m CPU load is high. Consider optimizing your website code, using a caching mechanism, or upgrading your server."
    else
        echo "CPU load is normal."
    fi
    echo
}

# Function to check memory usage in GB
check_memory_usage() {
    echo "------------------------------------"
    echo "Checking Memory Usage"
    echo "------------------------------------"
    free -g | awk 'NR==2{printf "Memory Usage: %s/%sGB (%.2f%%)\n", $3,$2,$3*100/$2 }'
    echo
}

# Function to check disk usage
check_disk_usage() {
    echo "------------------------------------"
    echo "Checking Disk Usage"
    echo "------------------------------------"
    df -h | awk '$NF=="/"{printf "Disk Usage: %d/%dGB (%s)\n", $3,$2,$5}'
    echo
}

# Function to check Apache (httpd) status
check_httpd_status() {
    echo "------------------------------------"
    echo "Checking Apache (httpd) Status"
    echo "------------------------------------"
    systemctl is-active httpd >/dev/null 2>&1 && echo "Apache (httpd) is running" || echo -e "\033[1;33mApache (httpd) is not running\033[0m"
    echo
}

# Function to check MySQL/MariaDB status
check_mysql_status() {
    echo "------------------------------------"
    echo "Checking MySQL/MariaDB Status"
    echo "------------------------------------"
    systemctl is-active mysqld >/dev/null 2>&1 || systemctl is-active mariadb >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "MySQL/MariaDB is running"
    else
        echo -e "\033[1;33mMySQL/MariaDB is not running\033[0m"
    fi
    echo
}

# Function to check MySQL sleep queries
check_mysql_sleep_queries() {
    echo "------------------------------------"
    echo "Checking MySQL Sleep Queries"
    echo "------------------------------------"
    sleep_queries=$(mysql -e "SHOW PROCESSLIST;" | grep -c "Sleep")
    echo "MySQL sleep queries: $sleep_queries"
    echo
}

# Function to check PHP-FPM max children
check_php_fpm_max_children() {
    echo "------------------------------------"
    echo "Checking PHP-FPM Max Children"
    echo "------------------------------------"
    last_max_children_log=$(grep 'max_children' /opt/cpanel/ea-php*/root/usr/var/log/php-fpm/error.log | tail -n 1)
    if [[ -n "$last_max_children_log" ]]; then
        echo -e "\033[1;33mPHP-FPM max children reached:\033[0m $last_max_children_log"
    else
        echo "PHP-FPM max children setting is adequate."
    fi
    echo
}

# Function to check Apache MaxRequestWorkers
check_apache_max_request_workers() {
    echo "------------------------------------"
    echo "Checking Apache MaxRequestWorkers"
    echo "------------------------------------"
    max_request_workers=$(grep 'MaxRequestWorkers' /etc/apache2/conf/httpd.conf | awk '{print $2}')
    echo "MaxRequestWorkers: $max_request_workers"
    echo
}

# Function to calculate and suggest optimal MaxRequestWorkers
calculate_max_request_workers() {
    echo "------------------------------------"
    echo "Calculating Optimal MaxRequestWorkers"
    echo "------------------------------------"

    # Get average memory usage of Apache processes
    avg_mem_per_httpd=$(ps -ylC httpd --sort:rss | awk '{sum+=$8} END {print sum/NR/1024}')
    echo "Average memory usage per Apache process: ${avg_mem_per_httpd}MB"

    # Get total available memory in MB
    total_mem=$(free -m | awk 'NR==2 {print $2}')
    # echo "Total available memory: ${total_mem}MB"

    # Estimate memory usage of non-Apache processes
    non_apache_mem=$(ps --no-headers -eo rss | awk '{sum+=$1} END {print sum/1024}')
    echo "Estimated memory usage by non-Apache processes: ${non_apache_mem}MB"

    # Calculate memory available for Apache
    mem_for_apache=$(echo "$total_mem - $non_apache_mem" | bc)
    echo "Memory available for Apache: ${mem_for_apache}MB"

    # Calculate optimal MaxRequestWorkers
    optimal_max_request_workers=$(echo "$mem_for_apache / $avg_mem_per_httpd" | bc)
    echo "Optimal MaxRequestWorkers: $optimal_max_request_workers"

    # Check current MaxRequestWorkers and ServerLimit
    current_max_request_workers=$(grep 'MaxRequestWorkers' /etc/apache2/conf/httpd.conf | awk '{print $2}')
    server_limit=$(grep 'ServerLimit' /etc/apache2/conf/httpd.conf | awk '{print $2}')

    # Suggest adjustments if needed
    if [ "$optimal_max_request_workers" -gt "$current_max_request_workers" ]; then
        echo -e "\033[1;33mSuggestion:\033[0m Consider increasing MaxRequestWorkers to $optimal_max_request_workers."
        if [ "$optimal_max_request_workers" -gt "$server_limit" ]; then
            echo -e "\033[1;33mNote:\033[0m You may also need to increase ServerLimit to $optimal_max_request_workers."
        fi
    else
        echo "Current MaxRequestWorkers setting is adequate."
    fi
    echo
}

# Function to provide suggestions
provide_suggestions() {
    echo "------------------------------------"
    echo "Providing Suggestions"
    echo "------------------------------------"

    # Suggestion for memory usage
    mem_usage=$(free -g | awk 'NR==2{printf "%.2f", $3*100/$2 }')
    if (( $(echo "$mem_usage > 95.0" | bc -l) )); then
        echo -e "\033[1;33mSuggestion:\033[0m Memory usage is high. Consider optimizing your database queries, using a caching mechanism, or upgrading your server."
    else
        echo "Memory usage is normal."
    fi

    # Suggestion for disk usage
    disk_usage=$(df -h | awk '$NF=="/"{printf "%d", $5}' | sed 's/%//g')
    if (( disk_usage > 98 )); then
        echo -e "\033[1;33mSuggestion:\033[0m Disk usage is high. Consider cleaning up unnecessary files, removing old backups, or upgrading your storage."
    else
        echo "Disk usage is normal."
    fi

    # Apache status suggestion
    if ! systemctl is-active httpd >/dev/null 2>&1; then
        echo -e "\033[1;33mSuggestion:\033[0m Apache (httpd) is not running. Consider restarting the service or checking the logs for errors."
    else
        echo "Apache (httpd) is running fine."
    fi

    # MySQL/MariaDB status suggestion
    if ! systemctl is-active mysql >/dev/null 2>&1 && ! systemctl is-active mariadb >/dev/null 2>&1; then
        echo -e "\033[1;33mSuggestion:\033[0m MySQL/MariaDB is not running. Consider restarting the service or checking the logs for errors."
    else
        echo "MySQL/MariaDB is running fine."
    fi

    # MySQL sleep queries suggestion
    if [ "$sleep_queries" -gt 1 ]; then
        echo -e "\033[1;33mSuggestion:\033[0m There are too many MySQL sleep queries. Consider optimizing your database queries or adjusting the wait_timeout setting."
    else
        echo "MySQL sleep queries are within normal limits."
    fi
}

# Main script execution
echo "===================================="
echo "  Website Load Check on cPanel Server"
echo "===================================="

check_cpu_load
check_memory_usage
check_disk_usage
check_httpd_status
check_mysql_status
check_mysql_sleep_queries
check_php_fpm_max_children
check_apache_max_request_workers
calculate_max_request_workers

provide_suggestions

echo "===================================="
echo "           Check Complete"
echo "===================================="
