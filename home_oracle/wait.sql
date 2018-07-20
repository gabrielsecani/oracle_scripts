-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/10g/session_waits.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database session waits.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_waits
-- Last Modified: 11/03/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 1000

COLUMN username FORMAT A20
COLUMN event FORMAT A30
COLUMN wait_class FORMAT A15

SELECT NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       sw.event,
       sw.wait_class,
       sw.wait_time,
       decode(s.status,'ACTIVE',1,-1)* sw.seconds_in_wait seconds_in_wait,
       sw.state,
       s.status
FROM   v$session_wait sw,
       v$session s
WHERE  s.sid = sw.sid
  and sw.event not in ('SQL*Net message from client')
--  and s.username = 'SYS'
ORDER BY decode(s.status,'ACTIVE',1,-1)* sw.seconds_in_wait DESC, s.SID asc;
--order by s.sid


