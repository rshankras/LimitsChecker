LimitsChecker
=============

Bash script for checking /etc/security/limits.conf

This script compares the current count of user's process with limits defined in /etc/security/limits.conf
Currently checks for nproc and nofile limit

Usage: ./limits_chk.sh (Assign required execute permission using chmod)
Usage: /limits_chk.sh -d (use -d switch for debugging)

Sample /var/log/limitslog output

Fri Nov  1 07:42:32 EDT 2013 Started:limits_chq
Fri Nov  1 07:43:03 EDT 2013 WARN nofile usage exceeded the minimum quota - user:testuser1, nofile_count:25, nofile_limit:30
Fri Nov  1 07:43:34 EDT 2013 ERROR nproc usage exceeded the maximum quota - user:testuser1, count:10, limit:10
Fri Nov  1 07:43:34 EDT 2013 ERROR nofile usage exceeded the maximum quota - user:testuser1, nofile_count:134, nofile_limit:30

Sample /var/log/limitslog output - with debug information.

Fri Nov  1 07:42:14 EDT 2013 Checking the count of nproc
Fri Nov  1 07:42:14 EDT 2013 Retrieved first pid 17060 for user->testuser1 
Fri Nov  1 07:42:14 EDT 2013 Retrieved soft limit set for user->testuser1, limit->10 
Fri Nov  1 07:42:14 EDT 2013 The nproc current usage in %->20 for user->testuser1 
Fri Nov  1 07:42:14 EDT 2013 Checking the count of nofile
Fri Nov  1 07:42:14 EDT 2013 nofile count for user->testuser1 is 25 
Fri Nov  1 07:42:14 EDT 2013 Retrieved first pid 17060 for user->testuser1 
Fri Nov  1 07:42:14 EDT 2013 Retrieved the nofile limit->30 for user->testuser1 
Fri Nov  1 07:42:14 EDT 2013 The nofile current usage in %->83 for user->testuser1 
Fri Nov  1 07:42:14 EDT 2013 WARN nofile usage exceeded the minimum quota - user:testuser1, nofile_count:25, nofile_limit:30