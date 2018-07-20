#!/bin/csh

echo "Executando $1"
date

cd /backup

source ./env.sh

if ( -f "rebuild.sql" ) then
  $ORACLE_BIN/sqlplus -S / as sysdba @rebuild.sql 
endif

date

