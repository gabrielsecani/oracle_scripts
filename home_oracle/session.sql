set linesize 300
set pagesize 999
col sql_text for a210
col username for a12
col osuser for a12
col sid for 999999
col spid for 99999999

select s.sid, s.serial#, p.spid, s.username, s.status, s.state, s.osuser, to_char(logon_time,'mm/dd/rrrr hh24:mi') logon_time,
	   s.lockwait, q.hash_Value, q.SQL_TEXT
 from v$session s
 left join v$sql q on q.hash_Value=s.sql_hash_value
 left join v$process p on p.addr = s.paddr
where s.username is not null
 and s.status <> 'INACTIVE'
 and s.audsid <> userenv('sessionid') 
order by s.lockwait, s.username, s.sid;
