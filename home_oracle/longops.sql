ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
set linesize 999
select SID, START_TIME,TOTALWORK, sofar, (sofar/totalwork) * 100 done, sysdate + TIME_REMAINING/3600/24 end_at
from v$session_longops
where totalwork > sofar
;

