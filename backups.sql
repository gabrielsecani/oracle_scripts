set pages 25 linesize 235
col STATUS format a24
col min format 99999.99
col START_TIME for a20
col END_TIME for a20
col INPUT_GB for 99,999.999
col OUTPUT_GB for 99,999.999

select d.INPUT_TYPE, d.STATUS, 
       D.INPUT_BYTES/1024/1024/1024 INPUT_GB,
       D.OUTPUT_BYTES/1024/1024/1024 OUTPUT_GB,
       to_char(D.START_TIME,'dd/mm/yyyy hh24:mi') start_time,
       to_char(D.END_TIME,'dd/mm/yyyy hh24:mi') end_time,
       to_char(D.elapsed_seconds/60,'9,990.00') min
  from V$RMAN_BACKUP_JOB_DETAILS D
  where D.START_TIME>=sysdate-5
 order by d.session_key
/

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


SELECT * FROM V$DATABASE_BLOCK_CORRUPTION order by 1,2;

SELECT distinct file# FROM V$DATABASE_BLOCK_CORRUPTION;

RECOVER CORRUPTION LIST;

BACKUP CHECK LOGICAL VALIDATE DATABASE;

select * from dba_extents where file_id=P1 and P2 between block_id and block_id + blocks - 1;
P1 - file
P2 - block


alter system set db_lost_write_protect=typical scope=both;
alter system set db_block_checking=full scope=both;
alter system set db_block_checksum=full scope=both;


select * from dba_extents where file_id=67 and 3235376 between block_id and block_id + blocks - 1;

RUN
{
  ALLOCATE CHANNEL c01 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c02 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c03 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c04 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c05 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c06 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c07 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c08 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c09 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c10 DEVICE TYPE DISK;

  RESTORE DATABASE;
  RECOVER DATABASE;

  BACKUP VALIDATE 
  CHECK LOGICAL 
  DATABASE 
  ARCHIVELOG ALL;
}

RUN
{
  ALLOCATE CHANNEL c1 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c2 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c3 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c4 DEVICE TYPE DISK;
  
  VALIDATE database SECTION SIZE 1200M;
}

RUN
{
  ALLOCATE CHANNEL c1 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c2 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c3 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c4 DEVICE TYPE DISK;
  BACKUP CHECK LOGICAL VALIDATE DATABASE SECTION SIZE 1200M;;
}

RUN
{
  ALLOCATE CHANNEL c1 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c2 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c3 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c4 DEVICE TYPE DISK;
  backup as copy datafile;
}

RUN
{
  ALLOCATE CHANNEL c1 DEVICE TYPE DISK;
  ALLOCATE CHANNEL c2 DEVICE TYPE DISK;
  restore datafile 29 from TAG TAG20180315T095609;
  RECOVER DATAFILE 29 from TAG TAG20180315T095609;
}
  validate backupset 1432 SECTION SIZE 1200M;
  FROM ACTIVE DATABASE


SELECT b.file#, b.block#, e.OWNER, e.SEGMENT_NAME, e.SEGMENT_TYPE
FROM V$DATABASE_BLOCK_CORRUPTION b
join dba_extents e on e.file_id=b.file#
 and b.block# between e.block_id and e.block_id + e.blocks - 1;
;

ALTER TABLESPACE SYSAUX FORCE LOGGING;       
ALTER TABLESPACE PSAPUNDO FORCE LOGGING;     
ALTER TABLESPACE PSAPTEMP FORCE LOGGING;     
ALTER TABLESPACE PSAPSR3 FORCE LOGGING;      
ALTER TABLESPACE PSAPSR3701 FORCE LOGGING;   
ALTER TABLESPACE PSAPSR3USR FORCE LOGGING; 


ALTER DATABASE ENABLE BLOCK CHANGE TRACKING;
select * from v$block_change_tracking;
