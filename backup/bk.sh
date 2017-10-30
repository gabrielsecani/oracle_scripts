#!/bin/csh

echo "Executando $1"
date

setenv ORACLE_HOME /oracle/EP0/11204 
setenv ORACLE_SID EP0
setenv ORACLE_BIN /oracle/EP0/11204/bin

cd /backup

##rotate log
setenv DATE_SUFFIX `date +"%Y"-"%m"-"%d"`
setenv BKLOG "backup_$1_$DATE_SUFFIX.log"

$ORACLE_BIN/rman target / cmdfile=backup_$1.rman append log=$BKLOG

# Delete old log files.
find backup*.log -mtime +30 -exec rm -f {} \;

echo "Fim $1"
date

setenv mailTO "gabriel.ribeiro@castgroup.com.br"

cat backup_$1.log $BKLOG | mail -s "[RAIA] - Monitoramento de backup $1 `uname -a`" $mailTO 

