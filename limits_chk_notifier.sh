#!/bin/bash
## This script is used for monitoring limitslog (/var/log/limitslog) for "WARN" and "ERROR" messages.
## If any log entries found matching the pattern then the details are mailed to the specified email address.
##
## Usage: ./limits_chk_notifier.sh (Assign required execute permission using chmod)
## Author: RShankar
##
## ---------------------------------------------------------------------------------------------------------
## limits_chk_notifer.sh ##

EMAIL_ADDRESS=ravishankar@outlook.in
LOG_FILE="/var/log/limitslog"
PATTERN1=WARN
PATTERN2=ERROR


tail -Fn0 $LOG_FILE | \
while read line ; do
        echo "$line" | grep -e $PATTERN1 -e $PATTERN2
        if [ $? = 0 ]
        then
             echo $line | mailx -s"limits log report" $EMAIL_ADDRESS
        fi
done