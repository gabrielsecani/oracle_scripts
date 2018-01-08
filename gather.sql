set serveroutput on
spool gather.log
/*
select To_char(Sysdate, 'dd/mm/yyyy hh24:mi:ss') as "Iniciando Delete as " from dual;

begin
DBMS_STATS.DELETE_SCHEMA_STATS('SAPSR3');
end;
/
prompt #####  FIM Delete stats  #####
*/

select To_char(Sysdate, 'dd/mm/yyyy hh24:mi:ss') "Iniciando Gather as " from dual;

begin
DBMS_STATS.GATHER_SCHEMA_STATS(ownname=>'SYS',  estimate_percent=>100, cascade=>true);
end;
/
begin
DBMS_STATS.GATHER_SCHEMA_STATS(ownname=>'SYSTEM',  estimate_percent=>100, cascade=>true);
end;
/
begin
DBMS_STATS.GATHER_SCHEMA_STATS('SYSTEM');
end;
/
begin
DBMS_STATS.GATHER_SCHEMA_STATS('SAPSR3');
end;
/
prompt #####  FIM Gather stats  #####

select To_char(Sysdate, 'dd/mm/yyyy hh24:mi:ss') "Fim" from dual;

spool off
exit

-- exec DBMS_STATS.GATHER_TABLE_STATS('SYS', 'DBA_FREE_SPACE');

nohup sqlplus / as sysdba <<EOF
spool galan.log
set time on
set SERVEROUTPUT on;
select To_char(Sysdate, 'dd/mm/yyyy hh24:mi:ss') "Iniciando Gather as " from dual;
exec DBMS_STATS.GATHER_TABLE_STATS('SAPSR3', 'BSIS', method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade=>true);
exec DBMS_STATS.GATHER_TABLE_STATS('SAPSR3', 'BSIK', method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade=>true);
exec DBMS_STATS.GATHER_TABLE_STATS('SAPSR3', 'BSID', method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade=>true);
exec DBMS_STATS.GATHER_TABLE_STATS('SAPSR3', 'BSAS', method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade=>true);
exec DBMS_STATS.GATHER_TABLE_STATS('SAPSR3', 'BSAK', method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade=>true);
exec DBMS_STATS.GATHER_TABLE_STATS('SAPSR3', 'BSAD', method_opt => 'FOR ALL COLUMNS SIZE AUTO', cascade=>true);
select To_char(Sysdate, 'dd/mm/yyyy hh24:mi:ss') "Finalizando Gather as " from dual;
spool off
exit
EOF

