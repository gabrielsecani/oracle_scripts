set pages 30 linesize 235
col STATUS format a24
COL MIN format 9990.00 heading "MINUTES"
col START_TIME for a17
col END_TIME for a17
col INPUT_GB for 99,990.000
col OUTPUT_GB for 99,990.000

prompt RMAN_BACKUP_JOB_DETAILS
select d.INPUT_TYPE, d.STATUS, 
       D.INPUT_BYTES/1024/1024/1024 INPUT_GB,
       D.OUTPUT_BYTES/1024/1024/1024 OUTPUT_GB,
       to_char(D.START_TIME,'dd/mm/yyyy hh24:mi') start_time,
       to_char(D.END_TIME,'dd/mm/yyyy hh24:mi') end_time,
       D.elapsed_seconds/60 min
  from V$RMAN_BACKUP_JOB_DETAILS D
  --where D.START_TIME>=sysdate-3
 order by d.START_TIME
/

COL RECID    FORMAT 99999
COL TAG       FORMAT A20
COL STATUS FORMAT A7
col HANDLE FORMAT A65 heading "MEDIA_HANDLE DESTINATION"
COL GBYTES format 9,990.00
COL GBYTES_TAG format 9,990.00

PROMPT BACKUP PIECE SET 
SELECT S.RECID, P.TAG, P.STATUS,
       TO_CHAR(p.START_TIME,'dd/mm/yyyy hh24:mi') START_TIME,
       TO_CHAR(p.COMPLETION_TIME,'hh24:mi') COMPLETION_TIME,
       P.elapsed_seconds/60 MIN,
       p.bytes/1024/1024/1024 GBYTES,
	   (SUM(p.bytes) over (partition by P.TAG)) /1024/1024/1024 GBYTES_TAG,
       p.HANDLE
FROM   V$BACKUP_PIECE P, V$BACKUP_SET S
WHERE  P.SET_STAMP = S.SET_STAMP
AND    P.SET_COUNT = S.SET_COUNT
--and P.START_TIME>=sysdate-5
order by P.START_TIME,P.TAG
/

COL STATUS FORMAT A11
col filename for a80 word_wrapped

PROMPT BACKUP IN PROGESS (BACKUP_ASYNC_IO)
select RMAN_STATUS_RECID, type, status, filename, buffer_size, buffer_count
   from v$backup_async_io
   where type <> 'AGGREGATE' and status = 'IN PROGRESS'
order by RMAN_STATUS_RECID
/

