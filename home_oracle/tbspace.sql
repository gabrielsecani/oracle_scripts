-- espaço por datafile
set linesize 200 pagesize 30
set feedback off
set echo off

col TS for a11
col FILE_ID for a3 heading "ID"
col FILE_NAME for a45
col STATUS for a10
col ONLINE_STATUS heading "ONLINE"
col total for 999,990.9 heading "Total (GB)"
col used for 999,990.9 heading "Used (GB)"
col free for 999,990.9 heading "Free (MB)"
col maxgb for 999,990.9 heading "Max (GB)"
col incby for 999,990.9 heading "IncBy (GB)"
col AUTOEXTENSIBLE for a4 heading "AUTO EXT"

compute sum   of total     on grupo
compute sum   of used      on grupo
compute sum   of free      on grupo
compute sum   of maxgb     on grupo
compute count of FILE_NAME on grupo
break on grupo SKIP 1 on report skip 1
COLUMN grupo NOPRINT;

select TABLESPACE_NAME grupo, TABLESPACE_NAME TS
     , to_char(ddf.FILE_ID) FILE_ID
     , ddf.FILE_NAME
     , ddf.ONLINE_STATUS, ddf.STATUS
     , SUM(DDF.BYTES)/1024/1024/1024 total
     , ROUND((SUM(DDF.BYTES) - SUM(NVL(DFS.BYTES,0)))/1024/1024/1024,1) used
     , round(sum(nvl(dfs.bytes,0))/1024/1024,1) free
     , round(sum(nvl(MAXBYTES,0)/1024/1024/1024),1) maxgb
     , ddf.AUTOEXTENSIBLE
     , round(sum(nvl(INCREMENT_BY,0)/1024/1024),1) incby
from DBA_DATA_FILES DDF
full outer join (select DFS.file_id, sum(nvl(DFS.bytes,0)) bytes from SYS.DBA_FREE_SPACE DFS group by DFS.file_id) DFS on dfs.file_id = ddf.file_id
--where DDF.TABLESPACE_NAME not in ('SYSAUX','SYSTEM')
group by DDF.TABLESPACE_NAME, ddf.file_id, DDF.FILE_NAME, ddf.AUTOEXTENSIBLE, ddf.ONLINE_STATUS, ddf.STATUS
order by ts, ddf.FILE_ID, FILE_NAME;

select DDF.TABLESPACE_NAME TS
     , to_char(DDF.FILE_ID) FILE_ID
     , DDF.FILE_NAME
     , '' ONLINE_STATUS, DDF.STATUS
     , SUM(DDF.BYTES)/1024/1024/1024 as total
     , round(sum(nvl(MAXBYTES,0)/1024/1024/1024),1) maxgb
     , ddf.AUTOEXTENSIBLE
     , round(sum(nvl(INCREMENT_BY,0)/1024/1024),1) incby
from DBA_TEMP_FILES DDF
group by DDF.TABLESPACE_NAME, ddf.AUTOEXTENSIBLE, DDF.STATUS, DDF.FILE_ID, DDF.FILE_NAME
order by DDF.FILE_ID;


select 'TEMP SPACE:' as ts, a.total, f.free, a.total - (f.free/1024) used
from (SELECT TABLESPACE_NAME, SUM(DDF.BYTES)/1024/1024/1024 total from DBA_TEMP_FILES DDF group by TABLESPACE_NAME) a,
   (select TABLESPACE_NAME, ROUND(SUM(NVL(DFS.FREE_SPACE,0))/1024/1024,1) free from SYS.DBA_TEMP_FREE_SPACE DFS group by TABLESPACE_NAME) f
where a.TABLESPACE_NAME=f.TABLESPACE_NAME;
-- select TABLESPACE_NAME, TABLESPACE_SIZE/1024/1024/1024 total, ALLOCATED_SPACE/1024/1024/1024 used, FREE_SPACE/1024/1024 free from DBA_TEMP_FREE_SPACE;


prompt === Table space UNDO ===
col undo_size 		for 999,990.00 heading "ACTUAL UNDO SIZE [MB]"
col undo_retention_sec heading "UNDO RETENTION [Sec]"
col undo_retention_min heading "UNDO RETENTION [Sec]"
col undo_needed 	for 999,990.000 heading"NEEDED UNDO SIZE [MB]"
SELECT SUBSTR(e.value,1,15) undo_retention_sec,
       to_number(SUBSTR(e.value,1,15))/60 undo_retention_min,
       d.undo_size/1024/1024 undo_size,
       (TO_NUMBER(e.value) * TO_NUMBER(f.value) * g.undo_block_per_sec) / (1024*1024) undo_needed
  FROM (
       SELECT SUM(a.bytes) undo_size
         FROM v$datafile a,
              v$tablespace b,
              dba_tablespaces c
        WHERE c.contents = 'UNDO'
          AND c.status = 'ONLINE'
          AND b.name = c.tablespace_name
          AND a.ts# = b.ts#
       ) d,
      v$parameter e,
      v$parameter f,
      (SELECT MAX(undoblks/((end_time-begin_time)*3600*24)) undo_block_per_sec FROM v$undostat) g
 WHERE e.name = 'undo_retention'
  AND f.name = 'db_block_size';


clear break;
clear columns;

column tablespace format a12
column total_mb format 999,999,999.99
column used_mb  format 999,999,999.99
column free_mb  format 999,999.99
column pct_used format 990.99
column graph format a25 heading "GRAPH (X=5%)"
column status format a7
column growth format 990.99 heading "Growth Per|Day(GB)"
compute sum of total_mb on report
compute sum of used_mb on report
compute sum of free_mb on report
break on report 
set lines 200 pages 100

with grow as (
	SELECT part.tsname,
		   Round(Avg(inc_used_size), 2) growth /* Growth of tablespace per day */
	 FROM 
	 (SELECT sub.days,
			 sub.tsname,
			 used_size - Lag (used_size, 1)
			  over (PARTITION BY sub.tsname ORDER BY sub.tsname, sub.days) inc_used_size /* getting delta increase using analytic function */
		   FROM  
		   (SELECT TO_CHAR(hsp.begin_interval_time,'MM-DD-YYYY') days,
			hs.tsname,
			MAX((hu.tablespace_usedsize* dt.block_size )/(1024*1024*1024)) used_size
		  from
			dba_hist_tbspc_space_usage hu, /* historical tablespace usage statistics */
			dba_hist_tablespace_stat hs , /* tablespace information from the control file */
			dba_hist_snapshot hsp, /* information about the snapshots in the Workload Repository */
			dba_tablespaces dt
		  where
			hu.snap_id = hsp.snap_id
			and hu.TABLESPACE_ID = hs.ts#
			and hs.tsname = dt.tablespace_name
			AND hsp.begin_interval_time > SYSDATE - 31 /* gathering info about last 30 days */
		  GROUP  BY To_char(hsp.begin_interval_time, 'MM-DD-YYYY'),
			hs.tsname
		  order by  hs.tsname,days) sub) part
	GROUP  BY part.tsname
	ORDER  BY part.tsname)
select  total.ts tablespace,
        DECODE(total.mb,null,'OFFLINE',dbat.status) status, total.mb total_mb,
        NVL(total.mb - free.mb,total.mb) used_mb,
        NVL(free.mb,0) free_mb,
        DECODE(total.mb,NULL,0,NVL(ROUND((total.mb - free.mb)/(total.mb)*100,2),100)) pct_used,
		grow.growth,
        CASE WHEN (total.mb IS NULL) THEN '['||RPAD(LPAD('OFFLINE',13,'-'),20,'-')||']'
        ELSE '['|| DECODE(free.mb,
                                    null,'XXXXXXXXXXXXXXXXXXXX',
                                    NVL(RPAD(LPAD('X',trunc((100-ROUND( (free.mb)/(total.mb) * 100, 2))/5),'X'),20,'-'),
         '--------------------'))||']' 
                END as GRAPH
from
 (select tablespace_name ts, sum(bytes)/1024/1024 mb from dba_data_files group by tablespace_name) total,
 (select tablespace_name ts, sum(bytes)/1024/1024 mb from dba_free_space group by tablespace_name) free,
        dba_tablespaces dbat, grow
where total.ts=free.ts(+) and
      total.ts=dbat.tablespace_name
	  and grow.tsname = dbat.tablespace_name
order by 1
/

set feedback on
