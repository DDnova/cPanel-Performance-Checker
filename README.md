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
====================================
  Website Load Check on cPanel Server
====================================
------------------------------------
Checking CPU Load
------------------------------------
Current load averages: 0.00, 0.01, 0.05
CPU load is normal.

------------------------------------
Checking Memory Usage
------------------------------------
Memory Usage: 0/3GB (0.00%)

------------------------------------
Checking Disk Usage
------------------------------------
Disk Usage: 17/40GB (42%)

------------------------------------
Checking Apache (httpd) Status
------------------------------------
Apache (httpd) is running

------------------------------------
Checking MySQL/MariaDB Status
------------------------------------
MySQL/MariaDB is running

------------------------------------
Checking MySQL Sleep Queries
------------------------------------
MySQL sleep queries: 0

------------------------------------
Checking PHP-FPM Max Children
------------------------------------
PHP-FPM max children setting is adequate.

------------------------------------
Checking Apache MaxRequestWorkers
------------------------------------
MaxRequestWorkers: 150

------------------------------------
Calculating Optimal MaxRequestWorkers
------------------------------------
Average memory usage per Apache process: 7.79248MB
Estimated memory usage by non-Apache processes: 1116.7MB
Memory available for Apache: 2672.3MB
Optimal MaxRequestWorkers: 342
Suggestion: Consider increasing MaxRequestWorkers to 342.
Note: You may also need to increase ServerLimit to 342.

------------------------------------
Providing Suggestions
------------------------------------
Memory usage is normal.
Disk usage is normal.
Apache (httpd) is running fine.
MySQL/MariaDB is running fine.
MySQL sleep queries are within normal limits.
====================================
           Check Complete
====================================
