set serveroutput on
spool gather.log
/*
select To_char(Sysdate, 'dd/mm/yyyy hh24:mi:ss') as "Iniciando Delete as " from dual;

begin
DBMS_STATS.DELETE_SCHEMA_STATS('DBUSR');
end;
/
prompt #####  FIM Delete stats  #####
*/

select To_char(Sysdate, 'dd/mm/yyyy hh24:mi:ss') "Iniciando Gather as " from dual;

begin
DBMS_STATS.GATHER_SCHEMA_STATS('DBUSR');
end;
/
prompt #####  FIM Gather stats  #####

select To_char(Sysdate, 'dd/mm/yyyy hh24:mi:ss') "Fim" from dual;

spool off
