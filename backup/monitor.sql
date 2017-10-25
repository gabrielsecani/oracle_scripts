-- http://snapshottooold.blogspot.com.br/2017/09/oracle-script-to-monitor-rman-running.html?m=0
col Timestarted format a16
set linesize 160
col opname for a18

select sid,opname,trunc((totalwork*8192)/1024/1024) "Total work(MB)",
 trunc((sofar*8192)/1024/1024) "Work Done(MB)", to_char(start_time, 'MM-DD-YYYY HH24:MI:SSAM') "Timestarted", trunc(time_remaining/60) "Time remaining(min)",round(elapsed_seconds/60) "Time Elasped(min)", round(sofar/totalwork*100,2) "% Complete" from v$session_longops
 where opname like 'RMAN%'
   and totalwork != 0
   and sofar != totalwork
 order by start_time, totalwork desc
/
