spool invalid_pre.lst
select substr(owner,1,12) owner,
substr(object_name,1,30) object,
substr(object_type,1,30) type, status from
dba_objects where status <>'VALID';
spool off

-- recompile
@?/rdbms/admin/utlrp.sql

