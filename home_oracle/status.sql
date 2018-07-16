set linesize 400 pagesize 50 feedback off
col DB_UNIQUE_NAME for a10 heading "UNIQ NAME"
col instance_number format 99 heading "INST#"
col INSTANCE_NAME format a10 heading "INST|NAME"
col SHUTDOWN_PENDING format a4 heading "SHUT|PEND"
col STARTUP_TIME heading "STARTUP|TIME"
col HOST_NAME format a15 heading "HOSTNAME"
col BLOCKED format a7 heading "BLOCKED"
col ACTIVE_STATE format a7 heading "ACTIVE|STATE"
col ARCHIVER format a8
set feedback off

PROMPT ## Instance Status
select INSTANCE_NUMBER, INSTANCE_NAME, HOST_NAME, STARTUP_TIME, VERSION
  from v$instance;

select INSTANCE_NUMBER, PARALLEL, THREAD#, ARCHIVER, LOG_SWITCH_WAIT, LOGINS, SHUTDOWN_PENDING
  from v$instance;

select INSTANCE_NUMBER, DATABASE_STATUS, INSTANCE_ROLE, ACTIVE_STATE, BLOCKED
  from v$instance;

PROMPT 
PROMPT ## Database Status
SELECT DB_UNIQUE_NAME, OPEN_MODE, DATABASE_ROLE, SWITCHOVER_STATUS
  FROM v$database;

select DB_UNIQUE_NAME, FLASHBACK_ON, protection_mode, protection_level
  from v$database;

PROMPT

archive log list;

Select
   THREAD#,
   max(SEQUENCE#) "last sequence", 
   APPLIED,
   REGISTRAR
From 
   V$ARCHIVED_LOG
 where applied not in ('NO')
group by thread#, APPLIED, registrar
order by 2,1,3,4;

-- Verify that the last sequence# received and the last sequence# applied to standby database.
select (SELECT DB_UNIQUE_NAME FROM v$database) DB_UNIQUE_NAME,
       al.thrd "Thread", almax "Last Seq Received", lhmax "Last Seq Applied", lhmax2 "Current log"
from (select thread# thrd, max(sequence#) almax
	  from v$archived_log
	  where resetlogs_change#=(select resetlogs_change# from v$database)
	  group by thread#) al,
	 (select thread# thrd, max(sequence#) lhmax
	  from v$log_history
	  where first_time=(select max(first_time) from v$log_history)
	  group by thread#) lh,
	 (SELECT THREAD# thrd, MAX(SEQUENCE#) lhmax2
	  FROM V$LOG_HISTORY
	  WHERE RESETLOGS_CHANGE# = (SELECT RESETLOGS_CHANGE#
	   FROM V$DATABASE_INCARNATION
	  WHERE STATUS = 'CURRENT')
	  GROUP BY THREAD#);

set feedback on
