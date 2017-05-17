--https://docs.oracle.com/cd/B10501_01/server.920/a96653/manage_ps.htm
clear screen
prompt # 8.5.3.1 Monitoring the Process Activities
SELECT PROCESS, CLIENT_PROCESS, SEQUENCE#, STATUS FROM V$MANAGED_STANDBY;
 
prompt # 8.5.3.2 Determining the Progress of Managed Recovery Operations
SELECT ARCHIVED_THREAD#, ARCHIVED_SEQ#, APPLIED_THREAD#, APPLIED_SEQ# FROM V$ARCHIVE_DEST_STATUS;

prompt # 8.5.3.3 Determining the Location and Creator of Archived Redo Logs
col name for a40
SELECT NAME, CREATOR, SEQUENCE#, APPLIED, COMPLETION_TIME FROM V$ARCHIVED_LOG;

prompt # 8.5.3.4 Viewing the Archive Log History
--SELECT FIRST_TIME, FIRST_CHANGE#, NEXT_CHANGE#, SEQUENCE# FROM V$LOG_HISTORY;

prompt # 8.5.3.5 Determining Which Logs Were Applied to the Standby Database
SELECT THREAD#, MAX(SEQUENCE#) AS "LAST_APPLIED_LOG" FROM V$LOG_HISTORY GROUP BY THREAD#;

prompt # 8.5.3.6 Determining Which Logs Were Not Received by the Standby Site
SELECT LOCAL.THREAD#, LOCAL.SEQUENCE# 
  FROM (SELECT THREAD#, SEQUENCE# FROM V$ARCHIVED_LOG WHERE DEST_ID=1) LOCAL 
 WHERE LOCAL.SEQUENCE# NOT IN (SELECT SEQUENCE# FROM V$ARCHIVED_LOG WHERE DEST_ID=2 AND THREAD# = LOCAL.THREAD#);

 -- dataguard status
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
set linesize 999
select * from v$DATAGUARD_STATUS;
