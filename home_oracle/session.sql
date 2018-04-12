set linesize 300
set pagesize 999
col sql_text for a60
col username for a15
select s.sid, s.serial#, s.username, s.status, s.state, s.osuser, to_char(logon_time,'mm/dd/rrrr hh24:mi') logon_time
 --, s.lockwait, p.spid, q.hash_Value
 , q.SQL_TEXT
 from v$session s 
 left join v$sql q on q.hash_Value=s.sql_hash_value
 left join v$process p on p.addr       = s.paddr
where s.username is not null
order by s.username;

select *
OWNER, MVIEW_NAME,QUERY,LAST_REFRESH_TYPE,LAST_REFRESH_DATE
from dba_mviews

select job, what from dba_jobs;
