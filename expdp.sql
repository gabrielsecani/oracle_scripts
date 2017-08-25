
set LINESIZE 999
COL DIRECTORY_NAME for A30
COL OWNER for A15
COL DIRECTORY_PATH for A60
select * from dba_directories;

drop directory EXPOMIGRACAO;

create directory EXPOMIGRACAO as '/mnt_hades/dump';
create directory EXPOMIGRACAO as '/migracao';
create directory EXPOMIGRACAO as '/mnt/migracao';
create directory EXPOMIGRACAO as '/mnt/migracao/dump';
create directory EXPOMIGRACAO as '/mnt_migracao';

create directory EXPOMIGRACAO as '/migracao/dmp';

create user exportcast identified by DRSAP01EP0;
grant dba to exportcast;
grant sysoper to exportcast;

*PARALLEL num de cpus
  show parameter cpu

expdp help=y

alter system set  pga_aggregate_target=6184752906

select username, default_tablespace from dba_users 
where default_tablespace not like ('SYS%');
and temporary_tablespace like (' NOME_PADRAO_SAP %') 

SCHEMAS=SAPSR3,OPS$EP0ADM,OPS$ORACLE,OPS$SAPSERVICEEP0 \

expdp exportcast/DRSAP01EP0 ATTACH=EXPORT_SAPSR3

expdp exportcast/DRSAP01EP0 \
  JOB_NAME=EXPORT_SAPSR3 DIRECTORY=EXPOMIGRACAO \
  DUMPFILE=drsapsr3_%U.dmp LOGFILE=drsapr3_export.log filesize=16G\
  FULL=N SCHEMAS=SAPSR3 \
  PARALLEL=10 \
  COMPRESSION=ALL

  
impdp exportcast/DRSAP01EP0 ATTACH=IMPORT_FULL

impdp exportcast/DRSAP01EP0 \
  JOB_NAME=IMPORT_FULL \
  DIRECTORY=EXPOMIGRACAO \
  DUMPFILE=drsapsr3_%U.dmp \  
  LOGFILE=drsapr3_import.log \
  PARALLEL=16 \
  TABLE_EXISTS_ACTION=REPLACE 

  TABLE_EXISTS_ACTION=SKIP 
  
  DUMPFILE=drsap_full01.dmp,drsap_full02.dmp,drsap_full03.dmp,drsap_full04.dmp,drsap_full05.dmp,drsap_full06.dmp,drsap_full07.dmp,drsap_full08.dmp,drsap_full09.dmp,drsap_full10 \


set pagesize 999
set linesize 999
clear columns
col owner_name for a10
col job_name for a30
col operation for a15
col job_mode for a15
select owner_name, job_name, operation, job_mode, state from dba_datapump_jobs;

expdp system/DRSAP01EP0 ATTACH=EXPORT_SAPSR3
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
    DBMS_OUTPUT.PUT_LINE(' handle: '|| H1);
    DBMS_DATAPUMP.STOP_JOB (H1,1,0);
  EXCEPTION when OTHERS then 
    DBMS_OUTPUT.PUT_LINE(chr(9)||' Erro: '|| sqlerrm);
  end;
end loop;
END;
/


EP0 % impdp exportcast/DRSAP01EP0 \
  JOB_NAME=IMPORT_FULL \
  DIRECTORY=EXPOMIGRACAO \
  DUMPFILE=drsap_full01.dmp,drsap_full02.dmp,drsap_full03.dmp,drsap_full04.dmp,drsap_full05.dmp,drsap_full06.dmp,drsap_full07.dmp,drsap_full08.dmp,drsap_full09.dmp,drsap_full10 \
  LOGFILE=drsap_import.log \
  PARALLEL=10 \
  TABLE_EXISTS_ACTION=SKIP \
  REMAP_DATAFILE="PSAPSR3701:PSAPSR3731"

  -- 
  ALTER SYSTEM SET EVENTS ‘10298 trace name context forever, level 32’;


  
  
Import: Release 11.2.0.4.0 - Production on Mon Aug 14 18:29:00 2017

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

Connected to: Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, Automatic Storage Management, OLAP, Data Mining
and Real Application Testing options
ORA-39001: invalid argument value
ORA-39000: bad dump file specification
ORA-31640: unable to open dump file "/mnt_hades/dump/drsap_full01.dmp" for read
ORA-27054: NFS file system where the file is created or resides is not mounted with correct options
Additional information: 5
Additional information: 18

