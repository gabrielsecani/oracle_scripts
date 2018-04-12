-- espaço por datafile
set linesize 200
set feedback off
col TS for a15
col FILE_ID for a7
col FILE_NAME for a45
col total heading "Total(GB)"
col used heading "Used(GB)"
col free heading "Free(MB)"
col maxgb heading "Max(GB)"
col incby heading "IncBy(GB)"
compute sum of total on report
compute sum of used on report
compute sum of free on report
compute sum of maxgb on report
compute count of FILE_NAME on report
break on report 
select TABLESPACE_NAME TS
     , to_char(ddf.FILE_ID) FILE_ID
     , ddf.FILE_NAME
     , ddf.ONLINE_STATUS, ddf.STATUS
     , SUM(DDF.BYTES)/1024/1024/1024 total
     , ROUND((SUM(DDF.BYTES) - SUM(NVL(DFS.BYTES,0)))/1024/1024/1024,1) used
     , round(sum(nvl(dfs.bytes,0))/1024/1024,1) free
     , round(sum(nvl(MAXBYTES,0)/1024/1024/1024),1) maxgb
     , (ddf.AUTOEXTENSIBLE) "AutoExt"
     , round(sum(nvl(INCREMENT_BY,0)/1024/1024),1) incby
from DBA_DATA_FILES DDF
full outer join (select DFS.file_id, sum(nvl(DFS.bytes,0)) bytes from SYS.DBA_FREE_SPACE DFS group by DFS.file_id) DFS on dfs.file_id = ddf.file_id
--where DDF.TABLESPACE_NAME not in ('SYSAUX','SYSTEM')
group by DDF.TABLESPACE_NAME, ddf.file_id, DDF.FILE_NAME, ddf.AUTOEXTENSIBLE, ddf.ONLINE_STATUS, ddf.STATUS
order by ts, FILE_ID, FILE_NAME;
/*
select a.ts,a.file_id,a.file_name, a.ONLINE_STATUS, a.STATUS, a.total, a.total - (f.free/1024) used, free, a.maxgb maxgb, a.AUTOEXTENSIBLE "AutoExt", a.incby
from (select DDF.TABLESPACE_NAME TS
     , listagg(to_char(FILE_ID), ' ') within group (order by FILE_ID) FILE_ID
     , listagg(FILE_NAME||' ('||DDF.BYTES/1024/1024/1024||'G)', ' ') within group (order by file_name) FILE_NAME
     , '' ONLINE_STATUS, DDF.STATUS
     , SUM(DDF.BYTES)/1024/1024/1024 total
     , round(sum(nvl(MAXBYTES,0)/1024/1024/1024),1) maxgb
     , ddf.AUTOEXTENSIBLE
     , round(sum(nvl(INCREMENT_BY,0)/1024/1024),1) incby
  from DBA_TEMP_FILES DDF
  group by DDF.TABLESPACE_NAME, ddf.AUTOEXTENSIBLE, DDF.STATUS) a,
  (select ROUND(SUM(NVL(DFS.FREE_SPACE,0))/1024/1024,1) free from SYS.DBA_TEMP_FREE_SPACE DFS) f
order by ts, FILE_ID, FILE_NAME;
*/

select DDF.TABLESPACE_NAME TS
     , to_char(DDF.FILE_ID) FILE_ID
     , DDF.FILE_NAME
     , '' ONLINE_STATUS, DDF.STATUS
     , SUM(DDF.BYTES)/1024/1024/1024 as "Total(GB)"
     , round(sum(nvl(MAXBYTES,0)/1024/1024/1024),1) "Max(GB)"
     , ddf.AUTOEXTENSIBLE
     , round(sum(nvl(INCREMENT_BY,0)/1024/1024),1) "IncBy(GB)"
from DBA_TEMP_FILES DDF
group by DDF.TABLESPACE_NAME, ddf.AUTOEXTENSIBLE, DDF.STATUS, DDF.FILE_ID, DDF.FILE_NAME
order by DDF.FILE_ID;

clear break;

select 'TEMP SPACE:' as ts, a.total, f.free, a.total - (f.free/1024) used
from (SELECT TABLESPACE_NAME, SUM(DDF.BYTES)/1024/1024/1024 total from DBA_TEMP_FILES DDF group by TABLESPACE_NAME) a,
   (select TABLESPACE_NAME, ROUND(SUM(NVL(DFS.FREE_SPACE,0))/1024/1024,1) free from SYS.DBA_TEMP_FREE_SPACE DFS group by TABLESPACE_NAME) f
where a.TABLESPACE_NAME=f.TABLESPACE_NAME;

-- select TABLESPACE_NAME, TABLESPACE_SIZE/1024/1024/1024 total, ALLOCATED_SPACE/1024/1024/1024 used, FREE_SPACE/1024/1024 free from DBA_TEMP_FREE_SPACE;

set feedback on
