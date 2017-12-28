-- SCRIPT TO LIST COMPLETED RMAN BACKUP TIMINGS.

set pages 60 linesize 235

col STATUS format a24
col min format 99999.99
col START_TIME for a20
col END_TIME for a20

select D.SESSION_KEY, D.INPUT_TYPE, D.STATUS, 
       round(D.INPUT_BYTES/1024/1024,3) INPUT_MB,
       round(D.OUTPUT_BYTES/1024/1024,3) OUTPUT_MB,
       to_char(D.START_TIME,'dd/mm/yyyy hh24:mi') start_time,
       to_char(D.END_TIME,'dd/mm/yyyy hh24:mi') end_time,
       D.elapsed_seconds/60 min
  from V$RMAN_BACKUP_JOB_DETAILS D
 order by session_key
/

COL RECID    FORMAT 99999
COL TAG       FORMAT A25
col MEDIA_HANDLE FORMAT A80
COL STATUS FORMAT A7

SELECT S.RECID, P.TAG, P.STATUS,
       to_char(P.START_TIME,'dd/mm/yyyy hh24:mi') start_time,
       P.elapsed_seconds/60 min, 
       P.HANDLE AS "MEDIA_HANDLE"
FROM   V$BACKUP_PIECE P, V$BACKUP_SET S
WHERE  P.SET_STAMP = S.SET_STAMP
AND    P.SET_COUNT = S.SET_COUNT
order by P.START_TIME
/
