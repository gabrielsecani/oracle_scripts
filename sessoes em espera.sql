SET LINESIZE 200
SET PAGESIZE 1000
COLUMN username FORMAT A20
COLUMN event FORMAT A35
SELECT NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       sw.event, sw.p1, sw.p2,
       sw.wait_time,
       sw.seconds_in_wait,
       sw.state 
FROM   v$session_wait sw,
       v$session s
WHERE  s.sid = sw.sid
--and s.sid=1243
--and s.username='REPORT'
and s.username is not null
and sw.EVENT <> 'SQL*Net message from client'
ORDER BY sw.seconds_in_wait DESC;