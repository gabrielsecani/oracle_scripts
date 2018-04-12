#!/bin/csh

echo "Executando $1"
date

cd /backup

source ./env.sh

rm -f backup_$1.log

setenv BACKUP_TAG `date +"%Y%m%d%H%M%S"`
echo $BACKUP_TAG

echo "BACKUP $1 START $BACKUP_TAG" >> backup_$1.log
date >> backup_$1.log
$ORACLE_BIN/rman target $ORAPWD cmdfile=backup_$1.rman using $BACKUP_TAG append log=backup_$1.log
echo "BACKUP $1 END" >> backup_$1.log

echo "BACKUP CROSSCHECK START" >> backup_$1.log
date >> backup_$1.log
$ORACLE_BIN/rman target $ORAPWD cmdfile=backup_xchk.rman append log=backup_$1.log
echo "BACKUP CROSSCHECK END" >> backup_$1.log

if ( -f "$1.sql" ) then
  echo "EXECUTING BEGIN SQL $1.sql" >> backup_$1.log
  $ORACLE_BIN/sqlplus $ORAPWD as sysdba @$1.sql >> backup_$1.log
  echo "EXECUTING END SQL $1.sql" >> backup_$1.log
endif

if ( -f "xchk.sql" ) then
  echo "EXECUTING BEGIN SQL xchk.sql" >> backup_$1.log
  $ORACLE_BIN/sqlplus $ORAPWD as sysdba @xchk.sql >> backup_$1.log
  echo "EXECUTING END SQL xchk.sql" >> backup_$1.log
endif

date >> backup_$1.log

echo "Files changed today in GB" >> backup_$1.log
find . -mtime 1 -type f -exec du -ga {} \; >> backup_$1.log

du -g ./* >> backup_$1.log
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

set SUBJ="[RAIA] - Monitoramento backup `uname -L` $1 $TEMERRWARN $DATE_SUFFIX "

echo "$DATE_SUFFIX $SUBJ" >> backup_$1.log
echo "$DATE_SUFFIX $SUBJ" >> $BKLOG

echo "sending mail with log to '$MAILTO'"
echo "$SUBJ"
cat backup_$1.log | mail -s "$SUBJ" $MAILTO
