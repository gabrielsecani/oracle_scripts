sqlplus / as sysdba <<EOF 

spool regorg_db.log
set time on
set SERVEROUTPUT on;
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';
select to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') fim, 'gathering database stats' STATUS from dual;
begin
  SYS.DBMS_STATS.GATHER_DATABASE_STATS();
end;
/
select to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') fim from dual;
spool off
exit

EOF
