set linesize 200
set pagesize 100
col DB_UNIQUE_NAME for a15
col instance_number format 99 heading "INST#"
col INSTANCE_NAME format a10 heading "INST|NAME"
col SHUTDOWN_PENDING format a4 heading "SHUT|PEND"
col STARTUP_TIME heading "STARTUP|TIME"
col HOST_NAME format a15 heading "HOSTNAME"
col BLOCKED format a7 heading "BLOCKED"
col ACTIVE_STATE format a7 heading "ACTIVE|STATE"
col ARCHIVER format a8

PROMPT ## Instance Status
select INSTANCE_NUMBER, INSTANCE_NAME, HOST_NAME, STARTUP_TIME, VERSION, SHUTDOWN_PENDING
  from v$instance;

select INSTANCE_NUMBER, PARALLEL, THREAD#, ARCHIVER, LOG_SWITCH_WAIT, LOGINS
  from v$instance;
  
select INSTANCE_NUMBER, DATABASE_STATUS, INSTANCE_ROLE, ACTIVE_STATE, BLOCKED
  from v$instance;

PROMPT ## Database Status
SELECT DB_UNIQUE_NAME, OPEN_MODE, DATABASE_ROLE, SWITCHOVER_STATUS
  FROM v$database;

select DB_UNIQUE_NAME, FLASHBACK_ON, protection_mode, protection_level
  from v$database;

archive log list;
