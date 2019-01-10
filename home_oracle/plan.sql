ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
set pages 30

@session

prompt Enter a value for SID
set termout off
define sid = &1
set termout on
prompt Setting PAGESIZE to &sid
set pagesize &sid

col SQL_ID new_val sql_id
col CHILD_NUMBER new_val child

SELECT A.SQL_ID,A.CHILD_NUMBER FROM V$SQL A,V$SESSION B
WHERE A.ADDRESS = B.SQL_ADDRESS AND B.SID = &sid;
set pages 40 lines 160

prompt ---------------------------- SHARED POOL ----------------------------
SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('&sql_id',&child,'ALL'));

prompt ----------------------------     AWR     ----------------------------
select * from table(dbms_xplan.display_awr('&sql_id',null,null,'ALL'));

undefine 1
