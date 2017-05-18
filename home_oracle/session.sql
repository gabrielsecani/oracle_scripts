set linesize 400
set pagesize 999
col sql_text for a60
col username for a15
select s.sid, s.serial#, s.username, s.status, s.state, q.SQL_TEXT
 from v$session s 
 join v$sql q on q.sql_id=s.sql_id
where username is not null
;
