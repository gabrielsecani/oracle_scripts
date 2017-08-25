ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
set linesize 999
select SID, username, status, START_TIME,TOTALWORK, sofar, (sofar/totalwork) * 100 done, sysdate + TIME_REMAINING/3600/24 end_at
from v$session_longops
where totalwork > sofar
AND opname NOT LIKE '%aggregate%'
AND opname like 'RMAN%'
/

select SID, START_TIME,TOTALWORK, sofar, (sofar/totalwork) * 100 done, sysdate + TIME_REMAINING/3600/24 end_at
from v$session_longops
where totalwork > sofar;

select sid, username, command, machine, program, logon_time, event, status from v$session where username is not null 
and username <> 'SAPSR3';
