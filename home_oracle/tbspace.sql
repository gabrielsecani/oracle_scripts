-- espaço por datafile
set linesize 200
col TS for a15
col FILE_ID for a6
col FILE_NAME for a45
compute sum of "Total(GB)" on report
compute sum of "Used(GB)" on report
compute sum of "Free(MB)" on report
compute sum of "Max(GB)" on report
compute count of FILE_NAME on report
break on report 
select TABLESPACE_NAME TS
     , to_char(ddf.FILE_ID) FILE_ID
     , ddf.FILE_NAME
     , ddf.ONLINE_STATUS, ddf.STATUS
     , SUM(DDF.BYTES)/1024/1024/1024 "Total(GB)"
     , ROUND((SUM(DDF.BYTES) - SUM(NVL(DFS.BYTES,0)))/1024/1024/1024,1) "Used(GB)"
     , round(sum(nvl(dfs.bytes,0))/1024/1024,1) "Free(MB)"
     , round(sum(nvl(MAXBYTES,0)/1024/1024/1024),1) "Max(GB)"
     , (ddf.AUTOEXTENSIBLE) "AutoExt"
     , round(sum(nvl(INCREMENT_BY,0)/1024/1024),1) "IncBy(MB)"
from DBA_DATA_FILES DDF
full outer join (select DFS.file_id, sum(nvl(DFS.bytes,0)) bytes from SYS.DBA_FREE_SPACE DFS group by DFS.file_id) DFS on dfs.file_id = ddf.file_id
--where DDF.TABLESPACE_NAME not in ('SYSAUX','SYSTEM')
group by DDF.TABLESPACE_NAME, ddf.file_id, DDF.FILE_NAME, ddf.AUTOEXTENSIBLE, ddf.ONLINE_STATUS, ddf.STATUS
union all
select a.ts,a.file_id,a.file_name, a.ONLINE_STATUS, a.STATUS, a.totalmb "Total(GB)", a.totalmb - (f.freemb/1024) "Used(GB)", f.freemb "Free(GB)", a.maxgb "Max(GB)", a.AUTOEXTENSIBLE "AutoExt", a.incby "IncBy(GB)"
from (select DDF.TABLESPACE_NAME TS
     , listagg(to_char(FILE_ID), ' ') within group (order by FILE_ID) FILE_ID
     , listagg(FILE_NAME||' ('||DDF.BYTES/1024/1024/1024||'G)', ' ') within group (order by file_name) FILE_NAME
     , '' ONLINE_STATUS, DDF.STATUS
     , SUM(DDF.BYTES)/1024/1024/1024 totalmb
     , round(sum(nvl(MAXBYTES,0)/1024/1024/1024),1) maxgb
     , ddf.AUTOEXTENSIBLE
     , round(sum(nvl(INCREMENT_BY,0)/1024/1024),1) incby
  from DBA_TEMP_FILES DDF
  group by DDF.TABLESPACE_NAME, ddf.AUTOEXTENSIBLE, DDF.STATUS) a,
  (select ROUND(SUM(NVL(DFS.FREE_SPACE,0))/1024/1024,1) freemb from SYS.DBA_TEMP_FREE_SPACE DFS) f
order by ts, FILE_ID, FILE_NAME;

