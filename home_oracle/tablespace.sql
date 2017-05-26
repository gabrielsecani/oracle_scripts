
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
        DECODE(total.mb,NULL,0,NVL(ROUND((total.mb - free.mb)/(total.mb)*100,2),100)) pct_used,
 CASE WHEN (total.mb IS NULL) THEN '['||RPAD(LPAD('OFFLINE',13,'-'),20,'-')||']'
 ELSE '['|| DECODE(free.mb,
                             null,'XXXXXXXXXXXXXXXXXXXX',
                             NVL(RPAD(LPAD('X',trunc((100-ROUND( (free.mb)/(total.mb) * 100, 2))/5),'X'),20,'-'),
  '--------------------'))||']' 
         END as GRAPH
from
 (select tablespace_name ts, sum(bytes)/1024/1024 mb from dba_data_files group by tablespace_name) total,
 (select tablespace_name ts, sum(bytes)/1024/1024 mb from dba_free_space group by tablespace_name) free,
        dba_tablespaces dbat
where total.ts=free.ts(+) and
      total.ts=dbat.tablespace_name
UNION ALL
select  sh.tablespace_name, 
        'TEMP',
 SUM(sh.bytes_used+sh.bytes_free)/1024/1024 total_mb,
 SUM(sh.bytes_used)/1024/1024 used_mb,
 SUM(sh.bytes_free)/1024/1024 free_mb,
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

PROMPT =============================================
PROMPT           Tablespace Capacity
PROMPT =============================================
CLEAR BREAKS
CLEAR COLUMNS
CLEAR COMPUTES
COLUMN TABLESPACE_NAME  FORMAT A20        HEADING "Tablespace"       JUSTIFY LEFT
COLUMN AMBYTES          FORMAT 99,999,999  HEADING 'Allocated|MBytes' 
COLUMN FMBYTES          FORMAT 9,999,999  HEADING 'Free|MBytes'      
COLUMN UMBYTES          FORMAT 9,999,999  HEADING 'Used|MBytes'      
COLUMN PCT_FREE         FORMAT 999.99     HEADING 'Pct|Free'        
BREAK ON REPORT
COMPUTE SUM LABEL "Total:" OF AMBYTES FMBYTES UMBYTES ON REPORT
SELECT A.TABLESPACE_NAME, A.BYTES/1024/1024 AMBYTES, (A.BYTES - F.BYTES)/1024/1024 UMBYTES,
       F.BYTES/1024/1024 FMBYTES, (F.BYTES/A.BYTES)*100 PCT_FREE
  FROM (SELECT TABLESPACE_NAME, SUM(BYTES) BYTES
          FROM DBA_DATA_FILES
          GROUP BY TABLESPACE_NAME) A,
       (SELECT TABLESPACE_NAME, SUM(BYTES) BYTES
          FROM DBA_FREE_SPACE
          GROUP BY TABLESPACE_NAME) F
  WHERE A.TABLESPACE_NAME = F.TABLESPACE_NAME (+)
  ORDER BY PCT_FREE;