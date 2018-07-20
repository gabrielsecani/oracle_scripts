#!/bin/csh

# get all tail process IDs
kill `ps -f | grep -i tail | grep -v grep | awk '{print $2}' `&

set LOGS = `find /oracle/${ORACLE_SID}/saptrace/ -name "*.log"|grep -v DELETED`

#if -f $log then echo "### tail -f -500 ${log} ###"; endif

foreach log ($LOGS)
 tail -f -500 $log&
end

echo "Reading..."
