set linesize 400
set pagesize 9999
col DB_UNIQUE_NAME for a15
col instance_number format 99 heading "#"
col INSTANCE_NAME format a10 heading "Inst Name"
col HOST_NAME format a15

PROMPT ## Instance Status
select INSTANCE_NUMBER, INSTANCE_NAME, HOST_NAME, STARTUP_TIME, VERSION
  from v$instance;

select INSTANCE_NUMBER, PARALLEL, THREAD#, ARCHIVER, LOG_SWITCH_WAIT, LOGINS, SHUTDOWN_PENDING
  from v$instance;
  
select INSTANCE_NUMBER, DATABASE_STATUS, INSTANCE_ROLE, ACTIVE_STATE, BLOCKED
  from v$instance;

PROMPT ## Database Status
SELECT DB_UNIQUE_NAME, OPEN_MODE, DATABASE_ROLE, SWITCHOVER_STATUS
 FROM v$database;

select DB_UNIQUE_NAME, FLASHBACK_ON, protection_mode, protection_level from v$database;

archive log list;
