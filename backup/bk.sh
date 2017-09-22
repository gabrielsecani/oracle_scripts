#!/bin/csh

date
echo "Executando $1"

setenv ORACLE_HOME /oracle/EP0/11204 
setenv ORACLE_SID EP0
setenv ORACLE_BIN /oracle/EP0/11204/bin

cd /backup

$ORACLE_BIN/rman target / cmdfile=backup_$1.rman append log=backup.log 
echo "FIM $1"
date

