set linesize 400
set pagesize 999
col sql_text for a60
col username for a15
select s.sid, s.serial#, s.username, s.status, s.state, q.SQL_TEXT
 from v$session s 
 join v$sql q on q.hash_Value=s.sql_hash_value
where username is not null
;
col SQL_TEXT for a200
--check active sessions
select s.sid, s.serial#, s.username, s.osuser, to_char(logon_time,'mm/dd/rrrr hh24:mi') logon_time, 
 s.lockwait, p.spid, q.hash_Value, q.SQL_TEXT
from v$sql     q, 
     v$session s, 
     v$process p 
where q.hash_Value = s.sql_hash_value 
  and s.status     = 'ACTIVE' 
  and p.addr       = s.paddr 
 -- and s.username='WEBLOGIC'
 --and s.sid =165
--and s.PROCESS='17113'
order by s.username;

select s.sid, s.serial#, s.username, s.status, s.state, q.sql_text
  from v$session s
  join v$sql q on q.hash_Value=s.sql_hash_value
 where username is not null
;

------
select INSTANCE_NUMBER, INSTANCE_NAME, HOST_NAME, version, STATUS from V$INSTANCE;

select DBID, name from V$DATABASE;

select username from DBA_USERS order by username;

select GRANTEE, GRANTED_ROLE from DBA_ROLE_PRIVS 
where GRANTEE in (select USERNAME from DBA_USERS)
order by 1,2;

