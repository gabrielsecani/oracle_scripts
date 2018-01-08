prompt "? SID: "
accept sid
col SQL_ID new_val sql_id
col CHILD_NUMBER new_val child

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';

SELECT A.SQL_ID,A.CHILD_NUMBER FROM V$SQL A,V$SESSION B
WHERE A.ADDRESS = B.SQL_ADDRESS AND B.SID=321;

SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('&sql_id',&child));

SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('5a6d490urazmd'));
SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('cvy83xnajq8ut',1));

set lines 200
set pages 30
col module for a35
col action for a10
select s.sid, s.sql_id, s.PREV_SQL_ID, s.SQL_EXEC_START, (sysdate - s.SQL_EXEC_START)*10000 delta, (s.SQL_EXEC_START - s.PREV_EXEC_START)*10000 delta_prev,
  s.PREV_EXEC_START, s.MODULE, s.ACTION, sw.SECONDS_IN_WAIT
from v$session s
join v$session_wait sw on sw.sid=s.sid
where sw.WAIT_CLASS = 'User I/O'
order by delta_prev, s.sql_id
/


select s.sid, s.sql_id, s.PREV_SQL_ID, s.SQL_EXEC_START, (s.SQL_EXEC_START - s.PREV_EXEC_START)*100000 delta, 
  s.PREV_EXEC_START, s.MODULE, s.ACTION
from v$session s
where sid = 260
order by s.sql_id;

where sid in (6,211,416);
where process = 14614638;


SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('0bzqjn3mdnpat'));
SELECT * FROM table (DBMS_XPLAN.DISPLAY_AWR('0bzqjn3mdnpat'));

SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('5rusks6v93c8j'));
SELECT * FROM table (DBMS_XPLAN.DISPLAY_AWR('5rusks6v93c8j'));
402
SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('axcqtff18c2dm'));
SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('99cjsmn792t7w'));

SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('5rusks6v93c8j'));

SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('9ud6d1fyr2vm0'));
SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('7djmc4wgjhn1f'));
SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('02dk2rj3kq9wn'));
SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('9ud6d1fyr2vm0'));

select count(*), sql_id from v$session group by sql_id

select distinct last_analyzed from dba_tables where owner='SAPSR3'
order by 1;

select sum(bytes)/1024/1024 MB, sum(bytes)/1024/1024/1024 GB, count(*) qtde from dba_segments where segment_name = 'BSIK';
select count(*) from SAPSR3.RBKP;

col INDEX_NAME for a20
col COLUMN_NAME for a20
select INDEX_NAME, COLUMN_NAME, COLUMN_POSITION from dba_ind_columns where TABLE_NAME = 'BSIS' order by INDEX_NAME, COLUMN_POSITION;

select INDEX_NAME, COLUMN_NAME, COLUMN_POSITION from dba_ind_columns where TABLE_NAME = 'BSAK' 
--and COLUMN_NAME in ('MANDT', 'BUKRS', 'LIFNR', 'BUDAT')
order by INDEX_NAME, COLUMN_POSITION;

CREATE INDEX SAPSR3.BSIK_DBA01 ON SAPSR3.BSIK (MANDT, BUKRS, AUGBL, CPUDT);
CREATE INDEX SAPSR3.J_1BNFDOC_DBA01 on SAPSR3.J_1BNFDOC (MANDT, DOCTYP, BELNR, GJAHR);
CREATE INDEX SAPSR3."BSAS~DBA01" ON SAPSR3.BSAS (MANDT, BUKRS, HKONT, BUDAT, AUGDT);
CREATE INDEX SAPSR3."BSAD~DBA01" ON SAPSR3.BSAD (MANDT, BUKRS, KUNNR, BUDAT, AUGDT);
CREATE INDEX SAPSR3."RBKP~DBA01" ON SAPSR3.RBKP (MANDT, BUKRS, LIFNR, XBLNR, WAERS, RMWWR, BLDAT, RBSTAT);



exec DBMS_STATS.GATHER_TABLE_STATS('SAPSR3', 'J_1BNFDOC', method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade=>true);

exec DBMS_STATS.GATHER_INDEX_STATS(ownName=>'SAPSR3', indname=> 'BSAD~DBA01', degree => 8, ESTIMATE_PERCENT => 100);

col SQL_TEXT for a120
select * from (select sql_text, PHYSICAL_READ_BYTES/1024/1024 PHYSICAL_READ_MB from v$sql order by PHYSICAL_READ_BYTES desc) where rownum < 10;

select count(*) from sapsr3.bsad;
select count(*) from sapsr3.bsid;
select count(*) from sapsr3.bsik;