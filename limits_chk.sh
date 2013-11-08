#!/bin/bash
## This script compares the current count of user's process with limits
## defined in /etc/security/limits.conf
## Need to include check for nofile, locks, cpu, nproc
## Usage: ./limits_chk.sh (Assign required execute permission using chmod)
## Usage: /limits_chk.sh -d (use -d switch for debugging)
## Author: RShankar
##
## Sample /var/log/limitslog output
##
## Fri Nov  1 07:42:32 EDT 2013 Started:limits_chq
## Fri Nov  1 07:42:33 EDT 2013 WARN nofile usage exceeded the minimum quota - user:testuser1, nofile_count:25, nofile_limit:30
## Fri Nov  1 07:43:03 EDT 2013 WARN nofile usage exceeded the minimum quota - user:testuser1, nofile_count:25, nofile_limit:30
## Fri Nov  1 07:43:34 EDT 2013 ERROR nproc usage exceeded the maximum quota - user:testuser1, count:10, limit:10
## Fri Nov  1 07:43:34 EDT 2013 ERROR nofile usage exceeded the maximum quota - user:testuser1, nofile_count:134, nofile_limit:30
## Fri Nov  1 07:44:05 EDT 2013 ERROR nofile usage exceeded the maximum quota - user:testuser1, nofile_count:37, nofile_limit:30
##
## Sample /var/log/limitslog output - with debug information.
## Fri Nov  1 07:42:14 EDT 2013 Checking the count of nproc
## Fri Nov  1 07:42:14 EDT 2013 Retrieved first pid 17060 for user->testuser1 
## Fri Nov  1 07:42:14 EDT 2013 Retrieved soft limit set for user->testuser1, limit->10 
## Fri Nov  1 07:42:14 EDT 2013 The nproc current usage in %->20 for user->testuser1 
## Fri Nov  1 07:42:14 EDT 2013 Checking the count of nofile
## Fri Nov  1 07:42:14 EDT 2013 nofile count for user->testuser1 is 25 
## Fri Nov  1 07:42:14 EDT 2013 Retrieved first pid 17060 for user->testuser1 
## Fri Nov  1 07:42:14 EDT 2013 Retrieved the nofile limit->30 for user->testuser1 
## Fri Nov  1 07:42:14 EDT 2013 The nofile current usage in %->83 for user->testuser1 
## Fri Nov  1 07:42:14 EDT 2013 WARN nofile usage exceeded the minimum quota - user:testuser1, nofile_count:25, nofile_limit:30
## --------------------------------------------------------------------------------------------------------------------------------

## limits_chk.sh ##

MIN_QUOTA=80 # in % used for warning.
MAX_QUOTA=90 # in % used for error.

# Specify the min count for nproc, nofile, cpu and locks.
# The limit check will be done only when the count is greater than the minimum value.

NPROC_MIN_VAL=1
NOFILE_MIN_VAL=1

TIME_INTERVAL=10 # Time interval for sleep.

DEBUG_ON=0

echo "$(date) Started:limits_chq" >> /var/log/limitslog

while getopts ":d" opt; do
      case $opt in
        d)
        DEBUG_ON=1
        echo "Debug ON!" >&2
        echo "$(date) Debug ON!" >> /var/log/limitslog
        ;;
        \?)
        echo "Invalid option: -$OPTARG" >&2
        ;;
    esac
done

while :
do
        if [ "$DEBUG_ON" -eq "1" ]; then
            echo "$(date) Start retrieving the user/process details " >> /var/log/limitslog
        fi
        # Get list of user/process
        ps hax -o user | sort | uniq -c|\
        while read count user; do
                
                if [ "$DEBUG_ON" -eq "1" ]; then
                    echo "$(date) Checking the count of nproc" >> /var/log/limitslog
                fi

                # Check whether the count of process (nproc) for a user has exceeded the limit.
                # do the check only if count greater than minimum count
                if [ $count -ge $NPROC_MIN_VAL ]; then

                    # Retrieve the pid from first row for the user
                    pid=$(ps h -U $user|awk '{print $1}'|head -1)

                    if [ "$DEBUG_ON" -eq "1" ]; then
                        echo "$(date) Retrieved first pid $pid for user->$user " >> /var/log/limitslog
                    fi

                    # Get soft limit from  the user limits
                    limit=$(cat /proc/$pid/limits 2>/dev/null | grep 'processes' |awk '{print $3}')

                    if [ "$DEBUG_ON" -eq "1" ]; then
                        echo "$(date) Retrieved soft limit set for user->$user, limit->$limit " >> /var/log/limitslog
                    fi

                    # Find out the current usage in %
                    if [ "$limit" != "" ]; then

                        x=$(echo $(( $count * 100 / $limit )))
                        if [ $? -ne 0 ]; then
                            echo "$(date) Limit->$limit for user->$user " >> /var/log/limitslog
                        elif [ $? -ge 0 ]; then            
                            ratio=$(( $count * 100 / $limit ))

                            if [ "$DEBUG_ON" -eq "1" ]; then
                                echo "$(date) The nproc current usage in %->$ratio for user->$user " >> /var/log/limitslog
                            fi

                            # Check if current usage exceeds MINIMUM or MAXIMUM quota. Write the info to /var/log/limitlog.
                            if [ $ratio -ge $MAX_QUOTA ]; then
                                echo "$(date) ERROR nproc usage exceeded the maximum quota - user:$user, count:$count, limit:$limit" >> /var/log/limitslog
                            elif [ $ratio -ge $MIN_QUOTA ]; then
                                echo "$(date) WARN nproc usage exceeded the minimum quota - user:$user, count:$count, limit:$limit"  >> /var/log/limitslog
                            fi
                        fi
                    fi

                fi

                ## Check whether no file count has exceeded the limit.
                if [ "$DEBUG_ON" -eq "1" ]; then
                    echo "$(date) Checking the count of nofile" >> /var/log/limitslog
                fi

                nofile_count=$(lsof -wbn +c15 -u $user 2>/dev/null | wc -l)

                if [ "$DEBUG_ON" -eq "1" ]; then
                    echo "$(date) nofile count for user->$user is $nofile_count " >> /var/log/limitslog
                fi

                # do the check only if nofile count is greater than minimum count
                if [ $nofile_count -ge $NOFILE_MIN_VAL ]; then

                     # Retrieve the pid from first row for the user
                    pid=$(ps h -U $user|awk '{print $1}'|head -1)

                    if [ "$DEBUG_ON" -eq "1" ]; then
                        echo "$(date) Retrieved first pid $pid for user->$user " >> /var/log/limitslog
                    fi

                    # get the nofile limits from proc
                    nofile_limit=$(cat /proc/$pid/limits 2>/dev/null| grep 'open files' | awk '{print $5}')

                    if [ "$DEBUG_ON" -eq "1" ]; then
                        echo "$(date) Retrieved the nofile limit->$nofile_limit for user->$user " >> /var/log/limitslog
                    fi

                    # Find out the current usage in %
                    if [ "$nofile_limit" != "" ]; then

                                x=$(echo $(( $nofile_count * 100 / $nofile_limit )))
                                if [ $? -ne 0 ]; then
                                    echo "$(date) nofile_limit->$nofile_limit for user->$user " >> /var/log/limitslog
                                elif [ $? -ge 0 ]; then
                                    ratio=$(( $nofile_count * 100 / $nofile_limit ))

                                    if [ "$DEBUG_ON" -eq "1" ]; then
                                        echo "$(date) The nofile current usage in %->$ratio for user->$user " >> /var/log/limitslog
                                    fi

                                    # Check if current usage exceeds MINIMUM or MAXIMUM quota. Write the info to /var/log/limitlog.
                                    if [ $ratio -ge $MAX_QUOTA ]; then
                                        echo "$(date) ERROR nofile usage exceeded the maximum quota - user:$user, nofile_count:$nofile_count, nofile_limit:$nofile_limit" >> /var/log/limitslog
                                    elif [ $ratio -ge $MIN_QUOTA ]; then
                                        echo "$(date) WARN nofile usage exceeded the minimum quota - user:$user, nofile_count:$nofile_count, nofile_limit:$nofile_limit"  >> /var/log/limitslog
                                    fi
                                fi
                        fi
                fi
        done

# Repeat the check for the defined period
sleep $TIME_INTERVAL
done