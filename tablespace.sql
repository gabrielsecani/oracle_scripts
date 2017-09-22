select OWNER, TABLE_NAME, TABLESPACE_NAME from all_tables where TABLESPACE_NAME = 'PSAPSR3USR';


set linesize 999
col name for a45
select FILE#,STATUS,ENABLED,NAME, CREATE_BYTES/1024./1024. CREATE_BYTES_MB, BYTES/1024./1024. BYTES_MB from v$datafile
order by file#;

select TABLESPACE_NAME,INITIAL_EXTENT,MIN_EXTENTS,MAX_EXTENTS,PCT_INCREASE,STATUS,ALLOCATION_TYPE from dba_tablespaces;
select tablespace_name ts
     , FILE_NAME
     , sum(bytes)/1024./1024. "Total(MB)"
 from dba_data_files ddf
group by DDF.TABLESPACE_NAME, DDF.FILE_NAME
order by DDF.TABLESPACE_NAME, DDF.FILE_NAME;

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
     , SUM(DDF.BYTES)/1024./1024./1024. "Total(GB)"
     , ROUND((SUM(DDF.BYTES) - SUM(NVL(DFS.BYTES,0)))/1024./1024./1024.,1) "Used(GB)"
     , round(sum(nvl(dfs.bytes,0))/1024/1024,1) "Free(MB)"
     , round(sum(nvl(MAXBYTES,0)/1024./1024./1024.),1) "Max(GB)"
     , (ddf.AUTOEXTENSIBLE) "AutoExt"
     , round(sum(nvl(INCREMENT_BY,0)/1024./1024.),1) "IncBy(MB)"
from DBA_DATA_FILES DDF
full outer join (select DFS.file_id, sum(nvl(DFS.bytes,0)) bytes from SYS.DBA_FREE_SPACE DFS group by DFS.file_id) DFS on dfs.file_id = ddf.file_id
--where DDF.TABLESPACE_NAME not in ('SYSAUX','SYSTEM')
group by DDF.TABLESPACE_NAME, ddf.file_id, DDF.FILE_NAME, ddf.AUTOEXTENSIBLE, ddf.ONLINE_STATUS, ddf.STATUS
union all
select a.ts,a.file_id,a.file_name, a.ONLINE_STATUS, a.STATUS, a.totalmb/1024 "Total(GB)", a.totalmb - f.freemb "Used(GB)", f.freemb "Free(MB)", a.maxgb "Max(GB)", a.AUTOEXTENSIBLE "AutoExt", a.incby "IncBy(MB)"
from (select DDF.TABLESPACE_NAME TS
		 , listagg(to_char(FILE_ID), ' ') within group (order by FILE_ID) FILE_ID
		 , listagg(FILE_NAME||' ('||DDF.BYTES/1024./1024./1024.||'G)', ' ') within group (order by file_name) FILE_NAME
		 , '' ONLINE_STATUS, DDF.STATUS
		 , SUM(DDF.BYTES)/1024./1024. totalmb
		 , round(sum(nvl(MAXBYTES,0)/1024./1024./1024.),1) maxgb
		 , ddf.AUTOEXTENSIBLE
		 , round(sum(nvl(INCREMENT_BY,0)/1024./1024.),1) incby
	from DBA_TEMP_FILES DDF
	group by DDF.TABLESPACE_NAME, ddf.AUTOEXTENSIBLE, DDF.STATUS) a,
	(select ROUND(SUM(NVL(DFS.FREE_SPACE,0))/1024/1024,1) freemb from SYS.DBA_TEMP_FREE_SPACE DFS) f
order by ts, FILE_ID, FILE_NAME;


col FILE_NAME for a45
select   DDF.TABLESPACE_NAME "TablespaceName"
         --, DDF.FILE_NAME
         , SUM(DDF.BYTES)/1024./1024./1024. "Total(GB)"
         , ROUND((SUM(DDF.BYTES) - SUM(NVL(DFS.BYTES,0)))/1024./1024./1024.,1) "Used(GB)"
         , round(sum(nvl(dfs.bytes,0))/1024/1024/1024,1) "Free(GB)"
from SYS.DBA_DATA_FILES DDF
full outer join (select DFS.file_id, sum(DFS.bytes) bytes from SYS.DBA_FREE_SPACE DFS group by DFS.file_id) DFS on dfs.file_id = ddf.file_id
group by ddf.tablespace_name--, ddf.file_name
order by DDF.TABLESPACE_NAME--, DDF.FILE_NAME
;

-- verifica utilização da temp
SELECT   A.tablespace_name tablespace, D.mb_total,
         SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
         D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM     v$sort_segment A,
         (
         SELECT   B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
         FROM     v$tablespace B, v$tempfile C
         WHERE    B.ts#= C.ts#
         GROUP BY B.name, C.block_size
         ) D
WHERE    A.tablespace_name = D.name
GROUP by A.tablespace_name, D.mb_total;

select s.osuser, s.process, s.username, s.serial#,
       sum(u.blocks)*vp.value/1024 sort_size
from   sys.v_$session s, sys.v_$sort_usage u, sys.v_$parameter vp
where  s.saddr = u.session_addr
  and  vp.name = 'db_block_size'
  and  s.osuser like '&1'
group  by s.osuser, s.process, s.username, s.serial#, vp.value
/

-- uso de temp total
SELECT   A.tablespace_name tablespace, D.mb_total,
         SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
         D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM     v$sort_segment A,
         (
         SELECT   B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
         FROM     v$tablespace B, v$tempfile C
         WHERE    B.ts#= C.ts#
         GROUP BY B.name, C.block_size
         ) D
WHERE    A.tablespace_name = D.name
GROUP by A.tablespace_name, D.mb_total;

 -- uso de temp por usuario
select s.osuser, s.process, s.username, s.serial#,
       sum(u.blocks)*vp.value/1024 sort_size
from   sys.v_$session s, sys.v_$sort_usage u, sys.v_$parameter vp
where  s.saddr = u.session_addr
  and  vp.name = 'db_block_size'
  and  s.osuser like '&1'
group  by s.osuser, s.process, s.username, s.serial#, vp.value
/

-----
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
ceil( blocks*&&blksize/1024/1024) -
ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ) savings
from dba_data_files a,
( select file_id, max(block_id+blocks-1) hwm
from dba_extents
group by file_id ) b
where a.file_id = b.file_id(+)
/



create pfile from spfile=/oracle/ED0/11204/dbs/spfileED0.2.ora;

alter system set control_files = '+DATA/ED0A/cntrlED0.dbf, +ARCH/ED0A/cntrled0.dbf' scope=spfile;
alter system set control_files = '+DATA/ed0a/cntrled0.dbf, +ARCH/ed0a/cntrled0.dbf' scope=spfile;

rmalias +data/ED0/cntrlED0.dbf
mkalias +DATA/ED0/CONTROLFILE/Current.256.936114003 +data/ED0A/cntrlED0.dbf
rmalias +ARCH/ED0/cntrlED0.dbf
mkalias +ARCH/ED0/CONTROLFILE/Current.256.936114003 +ARCH/ED0A/cntrlED0.dbf


ALTER TABLESPACE PSAPSR3731 RENAME TO PSAPSR3701;
ALTER TABLESPACE PSAPSR3701 RENAME TO PSAPSR3731;

ALTER TABLESPACE PSAPSR3701 OFFLINE NORMAL;
ALTER TABLESPACE PSAPSR3701 ONLINE;
ALTER TABLESPACE PSAPSR3701 RENAME DATAFILE '+DATA/ep0/datafile/psapsr3731.269.950552575' to '+DATA/ep0/datafile/psapsr3701.269.950552575'
ALTER TABLESPACE PSAPSR3701 drop datafile '+DATA/ep0/datafile/psapsr3731.270.950826801'

ALTER TABLESPACE PSAPSR3USR ONLINE;
ALTER TABLESPACE PSAPSR3USR OFFLINE NORMAL;
ALTER TABLESPACE PSAPSR3USR ADD DATAFILE '+DATA' SIZE 1G AUTOEXTEND OFF NEXT;
ALTER TABLESPACE PSAPSR3USR RENAME DATAFILE '+DATA/ep0/datafile/psapsr3usr.271.950826809' to '+DATA/EP0B/datafile/psapsr3usr.271.950826809';
ALTER DATABASE RENAME FILE '+DATA/ep0/datafile/psapsr3usr.271.950826809' to '+DATA/EP0B/datafile/psapsr3usr';

CREATE TABLESPACE PSAPSR3USR DATAFILE '+DATA' size 1G AUTOEXTEND ON NEXT 200M;


cp /mnt_hades/dump/psapsr3usr.271.950826809 +DATA/ep0b/datafile/psapsr3usr

ALTER TABLESPACE PSAPSR3701 ADD DATAFILE 
'+DATA' SIZE 10G AUTOEXTEND OFF,
'+DATA' SIZE 10G AUTOEXTEND OFF,
'+DATA' SIZE 10G AUTOEXTEND OFF,
'+DATA' SIZE 10G AUTOEXTEND OFF,
'+DATA' SIZE 10G AUTOEXTEND OFF,
'+DATA' SIZE 10G AUTOEXTEND OFF,
'+DATA' SIZE 10G AUTOEXTEND OFF,
'+DATA' SIZE 10G AUTOEXTEND OFF,
'+DATA' SIZE 10G AUTOEXTEND OFF;
;

ALTER DATABASE DATAFILE '+DATA/ep0b/datafile/system.257.952955253' resize 10G;
ALTER DATABASE DATAFILE '+DATA/ep0b/datafile/sysaux.259.952955255' resize 2G;
ALTER DATABASE DATAFILE '+DATA/ep0b/datafile/psapsr3.328.952955259' resize 30G;
ALTER DATABASE DATAFILE '+DATA/ep0/datafile/psapsr3701.270.952166727' resize 10G;
ALTER DATABASE DATAFILE '+DATA/ep0/datafile/psapsr3701.319.952166771' resize 10G;
ALTER DATABASE DATAFILE '+DATA/ep0/datafile/psapsr3701.320.952166399' resize 10G;
ALTER DATABASE DATAFILE '+DATA/ep0/datafile/psapsr3701.321.952166805' resize 10G;
ALTER DATABASE DATAFILE '+DATA/ep0/datafile/psapsr3731.269.950552575' resize 10G;
ALTER DATABASE DATAFILE '+DATA/ep0/datafile/psapsr3731.269.950552575' resize 10G;
ALTER TABLESPACE SYSAUX ADD DATAFILE '+DATA' size 10G;


DROP TABLESPACE PSAPSR3701 including contents;
CREATE TABLESPACE PSAPSR3701 DATAFILE '+DATA' size 10G AUTOEXTEND ON NEXT 200M;
ALTER TABLESPACE PSAPSR3701 ADD DATAFILE 
'+DATA' SIZE 10G AUTOEXTEND ON NEXT 200M,
'+DATA' SIZE 10G AUTOEXTEND ON NEXT 200M,
'+DATA' SIZE 10G AUTOEXTEND ON NEXT 200M,
'+DATA' SIZE 10G AUTOEXTEND ON NEXT 200M,
'+DATA' SIZE 10G AUTOEXTEND ON NEXT 200M,
'+DATA' SIZE 10G AUTOEXTEND ON NEXT 200M,
'+DATA' SIZE 10G AUTOEXTEND ON NEXT 200M,
'+DATA' SIZE 10G AUTOEXTEND ON NEXT 200M,
'+DATA' SIZE 10G AUTOEXTEND ON NEXT 200M
;

DROP TABLESPACE PSAPSR3 including contents;
CREATE TABLESPACE PSAPSR3 DATAFILE '+DATA' size 30G;




ALTER TABLESPACE PSAPSR3 ADD DATAFILE 
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF,
'+DATA' SIZE 30G AUTOEXTEND OFF
;

drop TABLESPACE PSAPTEMP;
CREATE TABLESPACE PSAPTEMP DATAFILE '+DATA' size 20G;

ALTER DATABASE TEMPFILE '+DATA/ep0/tempfile/psaptemp.264.950826139' resize 3G;
ALTER DATABASE TEMPFILE '+DATA/ep0b/tempfile/psaptemp.317.952968631' resize 31G;
ALTER DATABASE TEMPFILE '+DATA/ep0b/tempfile/psaptemp.329.952955257' resize 31G;
ALTER tablespace PSAPTEMP ADD TEMPFILE '+DATA' size 31G;

ALTER tablespace PSAPTEMP drop tempfile '+DATA/ed0a/tempfile/psaptemp.335.952796805';

ALTER TABLESPACE undotbs_01
     ADD DATAFILE '/u01/oracle/rbdb1/undo0102.dbf' AUTOEXTEND ON NEXT 100M
         MAXSIZE UNLIMITED;

CREATE UNDO TABLESPACE PSAPUNDO2 DATAFILE '+DATA' SIZE 1G REUSE AUTOEXTEND ON;
ALTER SYSTEM SET UNDO_TABLESPACE = PSAPUNDO2;
DROP TABLESPACE PSAPUNDO;
CREATE UNDO TABLESPACE PSAPUNDO DATAFILE '+DATA' SIZE 2G REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;
ALTER SYSTEM SET UNDO_TABLESPACE = PSAPUNDO;
DROP TABLESPACE PSAPUNDO2;

ALTER TABLESPACE PSAPUNDO DROP DATAFILE '+DATA/ep0b/datafile/psapundo.258.952955257';
ALTER TABLESPACE PSAPUNDO ADD DATAFILE '+DATA' SIZE 6G REUSE AUTOEXTEND ON;

