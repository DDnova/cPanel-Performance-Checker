# Website Load Check Script for cPanel Servers

This Bash script performs a check on a cPanel server to monitor various aspects of its performance, including CPU load, memory usage, disk usage, and the status of critical services such as Apache (httpd) and MySQL/MariaDB. Additionally, it provides suggestions for optimizing the server based on the findings.

Features
CPU Load Check:

Checks the current CPU load and compares it with the number of available CPU cores.
Provides suggestions if the CPU load is higher than the number of cores.
Memory Usage Check:

Displays the current memory usage in GB and percentage.
Provides suggestions if memory usage is higher than 80%.
Disk Usage Check:

Displays the current disk usage of the root partition.
Provides suggestions if disk usage is higher than 80%.
Apache (httpd) Status Check:

Checks if the Apache (httpd) service is running.
Provides suggestions if the service is not running.
MySQL/MariaDB Status Check:

Checks if either MySQL or MariaDB service is running.
Provides suggestions if neither service is running.
MySQL Sleep Queries Check:

Counts the number of MySQL sleep queries.
Provides suggestions if there are more than 10 sleep queries.
Apache MaxRequestWorkers Check:

Displays the current MaxRequestWorkers setting in the Apache configuration.
PHP-FPM max_children Check:

Checks for warnings in PHP-FPM logs indicating that the max_children setting has been reached.
Provides the most recent warning log entry as a suggestion if the setting is reached.
Calculate Optimal MaxRequestWorkers:

Calculates the optimal MaxRequestWorkers setting based on the available memory and average memory usage of Apache processes.
Provides suggestions to adjust MaxRequestWorkers and ServerLimit if necessary.
