#!/bin/bash

# Function to check CPU load and compare with number of cores
check_cpu_load() {
    echo "Checking CPU load..."
    load=$(uptime | awk -F'[a-z]:' '{ print $2 }')
    echo "Current load averages:$load"

    nproc_value=$(nproc)
    load_1=$(uptime | awk -F'[a-z]:' '{ print $2 }' | awk '{print $1}' | sed 's/,//')
    if (( $(echo "$load_1 > $nproc_value" | bc -l) )); then
        echo "Suggestion: CPU load is high. Consider optimizing your website code, using a caching mechanism, or upgrading your server."
    else
        echo "CPU load is normal."
    fi
}

# Function to check memory usage in GB
check_memory_usage() {
    echo "Checking memory usage..."
    free -g | awk 'NR==2{printf "Memory Usage: %s/%sGB (%.2f%%)\n", $3,$2,$3*100/$2 }'
}

# Function to check disk usage
check_disk_usage() {
    echo "Checking disk usage..."
    df -h | awk '$NF=="/"{printf "Disk Usage: %d/%dGB (%s)\n", $3,$2,$5}'
}

# Function to check Apache (httpd) status
check_httpd_status() {
    echo "Checking Apache (httpd) status..."
    systemctl is-active httpd >/dev/null 2>&1 && echo "Apache (httpd) is running" || echo "Apache (httpd) is not running"
}

# Function to check MySQL/MariaDB status
check_mysql_status() {
    echo "Checking MySQL/MariaDB status..."
    systemctl is-active mysql >/dev/null 2>&1 || systemctl is-active mariadb >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "MySQL/MariaDB is running"
    else
        echo "MySQL/MariaDB is not running"
    fi
}

# Function to check MySQL sleep queries
check_mysql_sleep_queries() {
    echo "Checking MySQL sleep queries..."
    sleep_queries=$(mysql -e "SHOW PROCESSLIST;" | grep -c "Sleep")
    echo "MySQL sleep queries: $sleep_queries"
}

# Function to check PHP-FPM max children
check_php_fpm_max_children() {
    echo "Checking PHP-FPM max children..."
    last_max_children_log=$(grep 'max_children' /opt/cpanel/ea-php*/root/usr/var/log/php-fpm/error.log | tail -n 1)
    echo "$last_max_children_log"
}
# Function to check Apache MaxRequestWorkers
check_apache_max_request_workers() {
    echo "Checking Apache MaxRequestWorkers..."
    max_request_workers=$(grep 'MaxRequestWorkers' /etc/apache2/conf/httpd.conf | awk '{print $2}')
    echo "MaxRequestWorkers: $max_request_workers"
}


# Function to calculate and suggest optimal MaxRequestWorkers
calculate_max_request_workers() {
    echo "Calculating optimal MaxRequestWorkers..."
    
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
        echo "Suggestion: Consider increasing MaxRequestWorkers to $optimal_max_request_workers."
        if [ "$optimal_max_request_workers" -gt "$server_limit" ]; then
            echo "Note: You may also need to increase ServerLimit to $optimal_max_request_workers."
        fi
    else
        echo "Current MaxRequestWorkers setting is adequate."
    fi
}

# Function to provide suggestions
provide_suggestions() {
    echo "Providing suggestions..."
    
    # Suggestion for memory usage
    mem_usage=$(free -g | awk 'NR==2{printf "%.2f", $3*100/$2 }')
    if (( $(echo "$mem_usage > 95.0" | bc -l) )); then
        echo "Suggestion: Memory usage is high. Consider optimizing your database queries, using a caching mechanism, or upgrading your server."
    else
        echo "Memory usage is normal."
    fi
    
    # Suggestion for disk usage
    disk_usage=$(df -h | awk '$NF=="/"{printf "%d", $5}' | sed 's/%//g')
    if (( disk_usage > 98 )); then
        echo "Suggestion: Disk usage is high. Consider cleaning up unnecessary files, removing old backups, or upgrading your storage."
    else
        echo "Disk usage is normal."
    fi
    
    # Apache status suggestion
    if ! systemctl is-active httpd >/dev/null 2>&1; then
        echo "Suggestion: Apache (httpd) is not running. Consider restarting the service or checking the logs for errors."
    else
        echo "Apache (httpd) is running fine."
    fi
    
    # MySQL/MariaDB status suggestion
    if ! systemctl is-active mysql >/dev/null 2>&1 && ! systemctl is-active mariadb >/dev/null 2>&1; then
        echo "Suggestion: MySQL/MariaDB is not running. Consider restarting the service or checking the logs for errors."
    else
        echo "MySQL/MariaDB is running fine."
    fi
    
    # MySQL sleep queries suggestion
    if [ "$sleep_queries" -gt 1 ]; then
        echo "Suggestion: There are too many MySQL sleep queries. Consider optimizing your database queries or adjusting the wait_timeout setting."
    else
        echo "MySQL sleep queries are within normal limits."
    fi

    # PHP-FPM max children suggestion
    last_max_children_log=$(grep 'reached max_children setting' /opt/cpanel/ea-php*/root/usr/var/log/php-fpm/error.log | tail -n 1)
    if [[ -n "$last_max_children_log" ]]; then
        echo "Suggestion: $last_max_children_log"
    else
        echo "PHP-FPM max children setting is adequate."
    fi
}

# Main script execution
echo "Website Load Check on cPanel Server"
echo "===================================="

check_cpu_load
check_memory_usage
check_disk_usage
check_httpd_status
check_mysql_status
check_mysql_sleep_queries
check_apache_max_request_workers
check_php_fpm_max_children
calculate_max_request_workers

provide_suggestions

echo "===================================="
echo "Check complete."
