# Website Load Check Script for cPanel Servers

This Bash script performs a check on a cPanel server to monitor various aspects of its performance, including CPU load, memory usage, disk usage, and the status of critical services such as Apache (httpd) and MySQL/MariaDB. Additionally, it provides suggestions for optimizing the server based on the findings.

## Detailed Breakdown

### CPU Load Check

- **Function**: Monitor CPU load and compare with CPU core count.
- **Suggestion Criteria**: CPU load > Number of CPU cores.

### Memory Usage Check

- **Function**: Display memory usage.
- **Critical Threshold**: 95% usage.
- **Output**: 
  - Current memory usage (GB).
  - Percentage usage.

### Disk Usage Check

- **Function**: Display root partition disk usage.
- **Critical Threshold**: 98% usage.
- **Output**: 
  - Current disk usage.
  - Percentage usage.

### Apache (httpd) Status Check

- **Function**: Check if Apache service is running.
- **Action**: 
  - Suggestion if Apache is not running.

### MySQL/MariaDB Status Check

- **Function**: Check if MySQL or MariaDB service is running.
- **Action**: 
  - Suggestion if neither service is running.

### MySQL Sleep Queries Check

- **Function**: Count MySQL sleep queries.
- **Critical Threshold**: More than 10 sleep queries.
- **Action**: 
  - Suggestion if sleep queries exceed the threshold.

### Apache MaxRequestWorkers Check

- **Function**: Display the current `MaxRequestWorkers` setting.
- **Output**: 
  - Current `MaxRequestWorkers` value.

### PHP-FPM max_children Check

- **Function**: Check PHP-FPM logs for `max_children` warnings.
- **Action**: 
  - Provide the most recent warning if `max_children` setting is reached.

### Calculate Optimal MaxRequestWorkers

- **Function**: Calculate optimal `MaxRequestWorkers` based on available memory and Apache process usage.
- **Action**: 
  - Suggest adjustments to `MaxRequestWorkers` and `ServerLimit` settings.

---

## Example Output

```shell
# CPU Load Check
CPU Load: 7.5
CPU Cores: 4
Suggestion: CPU load is high. Consider investigating running processes or upgrading your CPU.

# Memory Usage Check
Total Memory: 16 GB
Used Memory: 13.5 GB (84%)
Suggestion: Memory usage is above 80%. Consider adding more RAM or optimizing your applications.

# Disk Usage Check
Root Partition Usage: 90 GB (85%)
Suggestion: Disk usage is above 80%. Consider cleaning up disk space or adding more storage.

# Apache Status Check
Apache is running.

# MySQL/MariaDB Status Check
MySQL is running.

# MySQL Sleep Queries Check
Sleep Queries: 15
Suggestion: There are more than 10 sleep queries. Investigate long-running queries and optimize your database.

# Apache MaxRequestWorkers Check
MaxRequestWorkers: 150

# PHP-FPM max_children Check
Warning: [29-May-2024 12:34:56] WARNING: [pool www] server reached max_children setting (5), consider raising it

# Calculate Optimal MaxRequestWorkers
Optimal MaxRequestWorkers: 200
Suggestion: Based on your available memory, consider setting MaxRequestWorkers to 200 and ServerLimit to 200.

