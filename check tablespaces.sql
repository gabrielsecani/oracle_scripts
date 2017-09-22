clear columns
column tablespace format a30
column total_mb format 999,999,999.99
column used_mb format 999,999,999,999.99
column free_mb format 999,999,999.99
column pct_used format 999.99
column graph format a25 heading "GRAPH (X=5%)"
column status format a10
compute sum of total_mb on report
compute sum of used_mb on report
compute sum of free_mb on report
break on report 
set lines 200 pages 100
select  total.ts tablespace,
        DECODE(total.mb,null,'OFFLINE',dbat.status) status,
 total.mb total_mb,
 NVL(total.mb - free.mb,total.mb) used_mb,
 NVL(free.mb,0) free_mb,
 free.q free_part,
        DECODE(total.mb,NULL,0,NVL(ROUND((total.mb - free.mb)/(total.mb)*100,2),100)) pct_used,
 CASE WHEN (total.mb IS NULL) THEN '['||RPAD(LPAD('OFFLINE',13,'-'),20,'-')||']'
 ELSE '['|| DECODE(free.mb,
                             null,'XXXXXXXXXXXXXXXXXXXX',
                             NVL(RPAD(LPAD('X',trunc((100-ROUND( (free.mb)/(total.mb) * 100, 2))/5),'X'),20,'-'),
  '--------------------'))||']' 
         END as GRAPH
from
 (select tablespace_name ts, sum(bytes)/1024./1024. mb from dba_data_files group by tablespace_name) total,
 (select tablespace_name ts, sum(bytes)/1024./1024. mb, count(1) q from dba_free_space group by tablespace_name) free,
        dba_tablespaces dbat
where total.ts=free.ts(+) and
      total.ts=dbat.tablespace_name
UNION ALL
select  sh.tablespace_name, 
        'TEMP',
 SUM(sh.bytes_used+sh.bytes_free)/1024./1024. total_mb,
 SUM(sh.bytes_used)/1024./1024. used_mb,
 SUM(sh.bytes_free)/1024./1024. free_mb,
 0 free_part,
        ROUND(SUM(sh.bytes_used)/SUM(sh.bytes_used+sh.bytes_free)*100,2) pct_used,
        '['||DECODE(SUM(sh.bytes_free),0,'XXXXXXXXXXXXXXXXXXXX',
              NVL(RPAD(LPAD('X',(TRUNC(ROUND((SUM(sh.bytes_used)/SUM(sh.bytes_used+sh.bytes_free))*100,2)/5)),'X'),20,'-'),
                '--------------------'))||']'
FROM v$temp_space_header sh
GROUP BY tablespace_name
order by 6 
/
ttitle off
rem clear columns


-- datafile size really used

--Deve sempre ser executada antes de rodar a segunda
--   - Prepara os tamanhos e formatos das colunas a serem exibidas no sqlplus
--   - cria a variável blksize com o tamanho do db_block_size que será utilizado na query seguinte.

set verify off
column file_name format a50 word_wrapped
column smallest format 999,990 heading "Smallest|Size|Poss."
column currsize format 999,990 heading "Current|Size"
column savings format 999,990 heading "Poss.|Savings"
break on report
compute sum of savings on report
column value new_val blksize
select value from v$parameter where name = 'db_block_size'
/

--Segundo Set:

select file_name,
  ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ) smallest,
  ceil( blocks*&&blksize/1024/1024) currsize,
  ceil( blocks*&&blksize/1024/1024) - ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ) savings
from dba_data_files a, 
     ( select file_id, max(block_id+blocks-1) hwm from dba_extents group by file_id ) b
where a.file_id = b.file_id(+)
/

select * from v$loghist;
select * from v$log;

alter session set nls_date_format = 'YYYY-MM-DD';
alter session set nls_date_format = 'YYYY-MM-DD HH24';
COLUMN SIZE_IN_MB FOR 999,990.000

select sum(bytes)/1024/1024 SIZE_IN_MB from v$log where sequence# in (select sequence# from v$loghist where first_time>='2017-08-01');

select lh.first_time, sum(l.bytes)/1024/1024 SIZE_IN_MB
from v$log l
join v$loghist lh on lh.sequence# = l.sequence#
group by (lh.first_time);

select lh.first_time, sum(l.BLOCKS * l.BLOCK_SIZE)/1024/1024 SIZE_IN_MB
from v$ARCHIVED_LOG l
join v$loghist lh on lh.sequence# = l.sequence#
group by cube(lh.first_time);
order by 1;


select decode(grouping (trunc(COMPLETION_TIME)),1,'TOTAL',TRUNC(COMPLETION_TIME)) TIME
       --, sum(BACKUP_COUNT) BACKUP_COUNT,
       , avg(BACKUP_COUNT) BACKUP_COUNT,
       SUM(BLOCKS * BLOCK_SIZE) / 1024 / 1024 SIZE_IN_MB
  from V$ARCHIVED_LOG
 group by cube (trunc(COMPLETION_TIME)) 
 order by 1;

select  avg(size_in_mb) size_in_mb, max(size_in_mb), min(size_in_mb)
from (select trunc(COMPLETION_TIME) time
       , sum(BLOCKS * BLOCK_SIZE) / 1024 / 1024 SIZE_IN_MB
  from V$ARCHIVED_LOG
 group by (trunc(COMPLETION_TIME))
 )
 --where size_in_mb >= 6000
 order by 1;

select decode(grouping (trunc(COMPLETION_TIME,'MM')),1,'TOTAL',TRUNC(COMPLETION_TIME,'MM')) TIME, sum(BACKUP_COUNT) BACKUP_COUNT,
       SUM(BLOCKS * BLOCK_SIZE) / 1024 / 1024/1024 SIZE_IN_MB
  from V$ARCHIVED_LOG
 group by cube (trunc(COMPLETION_TIME,'MM')) 
 order by 1;

 