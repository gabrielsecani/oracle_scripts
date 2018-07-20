#!/bin/csh

echo "Executando $1"
date

cd /backup

source ./env.sh

rm -f monitor.log

setenv BACKUP_TAG `date +"%Y%m%d%H%M%S"`
echo $BACKUP_TAG

if ( -f "monitor.sql" ) then
  echo "EXECUTE SQL BEGIN monitor.sql" >> monitor.log
  $ORACLE_BIN/sqlplus $ORAPWD as sysdba @monitor.sql >> monitor.log
  echo "EXECUTE SQL END monitor.sql" >> monitor.log
endif

date >> monitor.log

echo "BACKUP END" >> monitor.log
date >> monitor.log

##rotate log
setenv DATE_SUFFIX `date +"%Y"-"%m"-"%d"`
setenv BKLOG "monitor_$DATE_SUFFIX.log"
cat monitor.log >> $BKLOG

# Delete old log files.
find monitor*.log -mtime +5 -exec mv {} old \;
find monitor*.log -mtime +30 -exec rm -f {} \;

echo "Fim $1"
date

## check for error or warning on log
set DATE_SUFFIX=`date +"%Y-%m-%d.%H:%M"`
set TEMERRWARN="OK"

if `grep -i -c -E 'warn' monitor.log` != 0 set TEMERRWARN="WARN"
if `grep -i -c -E 'err' monitor.log` != 0 set TEMERRWARN="*ERRO*"

set SUBJ="[RAIA] - Monitoramento monitor `uname -L` $1 $TEMERRWARN $DATE_SUFFIX "

echo "$DATE_SUFFIX $SUBJ" >> monitor.log
echo "$DATE_SUFFIX $SUBJ" >> $BKLOG

echo "sending mail with log to '$MAILTO'"
echo "$SUBJ"
cat monitor.log | mail -s "$SUBJ" $MAILTO

