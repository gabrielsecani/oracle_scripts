
*DIRECTORY: dba_directories
 - verificar oq existe ou criar um para o destino 
  create directory <name> as '/...';
  
create directory EXPOMIGRACAO as '/mnt/migracao';


*PARALLEL num de cpus
  show parameter cpu
  
  
nohup expdp system/admin360  DIRECTORY=EXPOMIGRACAO DUMPFILE=ARLAB_full%U.dmp LOGFILE=ARLAB_full.log FULL=Y PARALLEL=12 &

expdp help=y


impdp system/admin360 DIRECTORY=EXPOMIGRACAO DUMPFILE=ARLAB_full%U.dmp LOGFILE=ARLAB_full.log PARALLEL=10 TABLE_EXISTS_ACTION=ignore&

