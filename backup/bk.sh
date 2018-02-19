#!/bin/csh

echo "Executando $1"
date

cd /backup

source ./env.sh

rm -f backup_$1.log

echo "BACKUP $1 START" >> backup_$1.log
date >> backup_$1.log
$ORACLE_BIN/rman target $ORAPWD cmdfile=backup_$1.rman append log=backup_$1.log
echo "BACKUP $1 END" >> backup_$1.log

echo "BACKUP CROSSCHECK START" >> backup_$1.log
date >> backup_$1.log
$ORACLE_BIN/rman target $ORAPWD cmdfile=backup_xchk.rman append log=backup_$1.log
echo "BACKUP CROSSCHECK END" >> backup_$1.log

date >> backup_$1.log

find . -ctime -2 -exec du -g {} \; >> backup_$1.log

du -m /backup/ >> backup_$1.log
df -Pg . >> backup_$1.log

echo "BACKUP END" >> backup_$1.log
date >> backup_$1.log

##rotate log
setenv DATE_SUFFIX `date +"%Y"-"%m"-"%d"`
setenv BKLOG "backup_$1_$DATE_SUFFIX.log"
cat backup_$1.log >> $BKLOG

# Delete old log files.
find backup*.log -mtime +5 -exec mv {} old \;
find backup*.log -mtime +30 -exec rm -f {} \;

echo "Fim $1"
date

## check for error or warning on log
set DATE_SUFFIX=`date +"%Y-%m-%d.%H:%M"`
set TEMERRWARN="OK"

if `grep -i -c -E 'warn' backup_$1.log` != 0 set TEMERRWARN="WARN"
if `grep -i -c -E 'err' backup_$1.log` != 0 set TEMERRWARN="*ERRO*"

echo "sending mail with log to '$MAILTO'"
cat backup_$1.log | mail -s "[RAIA] - Monitoramento de backup $1 $DATE_SUFFIX $TEMERRWARN `uname -a`" $MAILTO
