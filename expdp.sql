
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

alter system set  pga_aggregate_target=6184752906

select username, default_tablespace from dba_users 
where default_tablespace not like ('SYS%') and temporary_tablespace like (' NOME_PADRAO_SAP %') 

SCHEMAS=SAPSR3,OPS$EP0ADM,OPS$ORACLE,OPS$SAPSERVICEEP0 \
nohup \
  expdp system/DRSAP01EP0 \
  JOB_NAME=EXPORT_FULL \
  DIRECTORY=EXPOMIGRACAO DUMPFILE=drsap_full%U.dmp LOGFILE=drsap_full.log \
  COMPRESSION=ALL \
  PARALLEL=12 \
  FULL=Y

nohup \
  impdp system/DRSAP01EP0 \
  JOB_NAME=IMPORT_FULL \
  DIRECTORY=EXPOMIGRACAO \
  DUMPFILE=drsap_full01.dmp,drsap_full02.dmp,drsap_full03.dmp,drsap_full04.dmp,drsap_full05.dmp,drsap_full06.dmp,drsap_full07.dmp,drsap_full08.dmp,drsap_full09.dmp,drsap_full10.dmp,drsap_full11.dmp,drsap_full12.dmp \
  LOGFILE=drsap_import.log \
  PARALLEL=16 \
  TABLE_EXISTS_ACTION=SKIP



set pagesize 999
set linesize 999
clear columns
col owner_name for a10
col job_name for a30
col operation for a15
col job_mode for a15
select owner_name, job_name, trim(operation) operation, job_mode, state from dba_datapump_jobs;

expdp system/DRSAP01EP0 ATTACH=EXPORT_FULL
expdp system/DRSAP01EP0 ATTACH=SYS_EXPORT_SCHEMA_01
expdp system/DRSAP01EP0 JOB_NAME=SYS_EXPORT_SCHEMA_01

set SERVEROUTPUT on
DECLARE
h1 NUMBER;
begin
for j in (select JOB_NAME,OWNER_NAME from dba_datapump_jobs order by 1)
LOOP
  DBMS_OUTPUT.PUT_LINE('JOB: '||J.OWNER_NAME||'.'||J.JOB_NAME);
  begin
    h1 := DBMS_DATAPUMP.ATTACH(J.JOB_NAME, J.OWNER_NAME);
    DBMS_OUTPUT.PUT_LINE(': '|| H1);
    DBMS_DATAPUMP.STOP_JOB (H1,1,0);
  EXCEPTION when OTHERS then 
    DBMS_OUTPUT.PUT_LINE(chr(9)||' Erro: '|| sqlerrm);
  end;
end loop;
END;
/

