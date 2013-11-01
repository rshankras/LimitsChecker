LimitsChecker
=============

Bash script for checking /etc/security/limits.conf

This script compares the current count of user's process with limits defined in /etc/security/limits.conf
Currently checks for nproc and nofile limit

Usage: ./limits_chk.sh (Assign required execute permission using chmod)
Usage: /limits_chk.sh -d (use -d switch for debugging)

The log file (limitslog) will be available under /var/log/.
