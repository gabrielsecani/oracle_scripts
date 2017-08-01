
set LINESIZE 999
COL DIRECTORY_NAME for A30
COL OWNER for A15
COL DIRECTORY_PATH for A60

select * from dba_directories;

drop directory EXPOMIGRACAO;

create directory EXPOMIGRACAO as '/mnt/migracao';

create directory EXPOMIGRACAO as '/migracao/dmp';


*PARALLEL num de cpus
  show parameter cpu

expdp help=y


nohup expdp system/DRSAP01EP0 DIRECTORY=EXPOMIGRACAO DUMPFILE=drsap_full%U.dmp LOGFILE=drsap_full.log FULL=Y PARALLEL=8 &

nohup impdp system/DRSAP01EP01 DIRECTORY=EXPOMIGRACAO DUMPFILE=drsap_full%U.dmp LOGFILE=drsap_full.log PARALLEL=8 TABLE_EXISTS_ACTION=ignore&

