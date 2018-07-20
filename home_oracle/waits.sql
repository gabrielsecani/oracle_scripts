set lines 200
set pages 30
col module for a35
col action for a10
col sql_id for a15
select s.sid, s.sql_id, s.PREV_SQL_ID, s.SQL_EXEC_START, (sysdate - s.SQL_EXEC_START)*10000 delta, (s.SQL_EXEC_START - s.PREV_EXEC_START)*10000 delta_prev,
  s.PREV_EXEC_START, s.MODULE, s.ACTION, sw.SECONDS_IN_WAIT
from v$session s
join v$session_wait sw on sw.sid=s.sid
where sw.WAIT_CLASS = 'User I/O'
order by delta, delta_prev, 2
/
