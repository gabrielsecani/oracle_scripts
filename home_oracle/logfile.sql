set linesize 400
set pagesize 9999
col "type" for a7
col member for a42

select * from v$logfile
order by group#, member
/
archive log list;

SELECT GROUP#, ARCHIVED, STATUS FROM V$LOG
order by 1
/

