set pages 30 linesize 235
COL RECID    FORMAT 99999
COL TAG       FORMAT A25
col MEDIA_HANDLE FORMAT A60
COL STATUS FORMAT A7
COL IL FORMAT A3
COL MIN format 9,990.00
COL GBYTES format 9,990.00
COL GBYTES_TAG format 9,990.00

SELECT S.RECID, P.TAG, P.STATUS,
       TO_CHAR(p.START_TIME,'dd/mm/yyyy hh24:mi') START_TIME,
       TO_CHAR(p.COMPLETION_TIME,'hh24:mi') COMPLETION_TIME,
       P.elapsed_seconds/60 MIN,
       p.bytes/1024/1024/1024 GBYTES,
	   (SUM(p.bytes) over (partition by P.TAG)) /1024/1024/1024 GBYTES_TAG,
       p.HANDLE as "MEDIA_HANDLE"
FROM   V$BACKUP_PIECE P, V$BACKUP_SET S
WHERE  P.SET_STAMP = S.SET_STAMP
AND    P.SET_COUNT = S.SET_COUNT
and P.START_TIME>=sysdate-3
order by P.TAG,P.START_TIME
/

PROMPT Backup in progess
COL STATUS FORMAT A11
col filename for a80 word_wrapped
select RMAN_STATUS_RECID, type, status, filename, buffer_size, buffer_count
   from v$backup_async_io
   where type <> 'AGGREGATE' and status = 'IN PROGRESS'
order by RMAN_STATUS_RECID
/

