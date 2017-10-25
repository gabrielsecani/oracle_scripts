-- SCRIPT TO LIST COMPLETED RMAN BACKUP TIMINGS.

col STATUS format a24
col min format 99999.99
col START_TIME for a20
col END_TIME for a20
set pages 99 linesize 235

select SESSION_KEY, INPUT_TYPE, STATUS,
       to_char(START_TIME,'dd/mm/yyyy hh24:mi') start_time,
       to_char(END_TIME,'dd/mm/yyyy hh24:mi') end_time,
       elapsed_seconds/60 min
  from V$RMAN_BACKUP_JOB_DETAILS
 order by session_key;
/
