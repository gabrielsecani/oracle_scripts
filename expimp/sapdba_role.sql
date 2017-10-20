-- @(#) $Id: //bas/CGK/src/ccm/rsbr/sapdba_role.sql#1 $ SAP
-- Create/update sapdba role
-- This script can only be run on Oracle 9i or higher
-- Calling syntax (sapdba_role.sql in current directory):
-- sqlplus /nolog @sapdba_role <SAPSCHEMA_ID> [<PDB_NAME>]
-- <SAPSCHEMA_ID> - for owner SAPR3: R3, SAP<SID>: <SID>, SAP<SID>DB: <SID>DB
-- <PDB_NAME> - pluggable database name (only for multitenant database)
-- For ROOT container database: sqlplus /nolog @sapdba_role NONE ROOT
-- Log file sapdba_role.log will be created in current directory

set echo off;
set termout off;
set linesize 250;
spool sapdba_role.log

whenever sqlerror exit sql.sqlcode

connect / as sysdba;

whenever sqlerror continue

define User = ' '

variable Owner	VARCHAR2(30)
variable Pref_os_auth	VARCHAR2(30)
variable Pref_com_user	VARCHAR2(30)

execute -
 if length('&&1') >= 6 and substr(upper('&&1'), 1, 3) = 'SAP' or upper('&&1') = 'SAPR3' then -
  :Owner := upper('&&1'); -
 else -
  :Owner := upper('SAP&&1'); -
 end if

column arg2 noprint new_value 2
select null arg2 from dual where 1 = 2;

declare

Curs		INTEGER;
Statement	VARCHAR2(128);
RetWert		INTEGER;
V_User		VARCHAR2(30);
role_exists	EXCEPTION;

pragma exception_init (role_exists, -1921);

cursor	Curs_1	is select username from sys.dba_users where username like :Pref_os_auth or username like :Pref_com_user;

begin

Curs := dbms_sql.open_cursor;

begin
 select upper(value) || '%' into :Pref_os_auth from v$parameter where name = 'os_authent_prefix';
exception
 when others then
 :Pref_os_auth := 'OPS$%';
end;

if '&&2' is not null and length('&&2') >= 3 then
 begin
  select upper(value) || 'BRT$%' into :Pref_com_user from v$parameter where name = 'common_user_prefix';
 exception
  when others then
  :Pref_com_user := 'C##BRT$%';
 end;
else
 :Pref_com_user := 'BRT$%';
end if;

if '&&2' is not null and length('&&2') >= 3 and '&&2' <> 'ROOT' then
 begin
  Statement := 'alter session set container = "&2"';
  dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
  RetWert := dbms_sql.execute(Curs);
 end;
end if;

if '&&2' is null or length('&&2') >= 3 and '&&2' <> 'ROOT' then
 begin
  Statement := 'create role sapdba';
  dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
  RetWert := dbms_sql.execute(Curs);
 exception
  when role_exists then
  NULL;
 end;
end if;

begin
 open curs_1;
 loop
  fetch curs_1 into V_User;
  exit when curs_1%notfound;
  if '&&2' is null or length('&&2') >= 3 and '&&2' <> 'ROOT' then
   begin
    Statement := 'grant sapdba to "' || V_User || '"';
    dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
    RetWert := dbms_sql.execute(Curs);
   end;
  end if;
  if '&&2' is not null and length('&&2') >= 3 and '&&2' = 'ROOT' then
   begin
    Statement := 'grant create session to "' || V_User || '" container = all';
    dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
    RetWert := dbms_sql.execute(Curs);
   end;
   begin
    Statement := 'grant alter session to "' || V_User || '" container = all';
    dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
    RetWert := dbms_sql.execute(Curs);
   end;
   begin
    Statement := 'grant set container to "' || V_User || '" container = all';
    dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
    RetWert := dbms_sql.execute(Curs);
   end;
   begin
    Statement := 'grant select_catalog_role to "' || V_User || '" container = current';
    dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
    RetWert := dbms_sql.execute(Curs);
   end;
   begin
    Statement := 'grant create synonym to "' || V_User || '" container = current';
    dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
    RetWert := dbms_sql.execute(Curs);
   end;
   begin
    Statement := 'grant analyze any dictionary to "' || V_User || '" container = current';
    dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
    RetWert := dbms_sql.execute(Curs);
   end;
   begin
    Statement := 'grant analyze any to "' || V_User || '" container = current';
    dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
    RetWert := dbms_sql.execute(Curs);
   end;
   begin
    Statement := 'grant gather_system_statistics to "' || V_User || '" container = current';
    dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
    RetWert := dbms_sql.execute(Curs);
   end;
   begin
    Statement := 'alter user "' || V_User || '" set container_data = all for v_$pdbs container = current';
    dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
    RetWert := dbms_sql.execute(Curs);
   end;
   begin
    Statement := 'alter user "' || V_User || '" set container_data = all for dba_pdbs container = current';
    dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
    RetWert := dbms_sql.execute(Curs);
   end;
  end if;
 end loop;
 close curs_1;
end;

if '&&2' is not null and length('&&2') >= 3 and '&&2' <> 'ROOT' then
 begin
  Statement := 'grant sapdba to sysbackup';
  dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
  RetWert := dbms_sql.execute(Curs);
 end;
end if;

begin
 select username into V_User from sys.dba_users where username = :Owner;
exception
 when others then
 :Owner := 'SAPSR3';
end;

dbms_sql.close_cursor(Curs);

end; -- procedure
/

spool off
set echo off;
set termout off;
whenever sqlerror exit success

declare

Curs		INTEGER;
Statement	VARCHAR2(128);
RetWert		NUMBER;

begin

Curs := dbms_sql.open_cursor;

-- trigger a dummy error to exit the script for ROOT container
if '&&2' is not null and length('&&2') >= 3 and '&&2' = 'ROOT' then
 begin
  Statement := 'drop role sapdba';
  dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
  RetWert := dbms_sql.execute(Curs);
 end;
end if;

dbms_sql.close_cursor(Curs);

end; -- procedure
/

whenever sqlerror continue
spool sapdba_role.log append

grant sapdba to system;
grant select_catalog_role to sapdba;
grant select on sys.file$ to sapdba;
grant select on sys.ts$ to sapdba;
grant select on sys.uet$ to sapdba;
grant select on sys.fet$ to sapdba;
grant select on sys.obj$ to sapdba;
grant select on sys.seg$ to sapdba;
grant select on sys.tab$ to sapdba;
grant select on sys.ind$ to sapdba;
grant select on sys.clu$ to sapdba;
grant select on sys.lob$ to sapdba;
grant select on sys.user$ to sapdba;
grant select on sys.object_usage to sapdba;
grant select on sys.redef_object$ to sapdba;
grant create session to sapdba;
grant create view to sapdba;
grant create synonym to sapdba;
grant alter session to sapdba;
grant alter system to sapdba;
grant alter database to sapdba;
grant alter tablespace to sapdba;
grant alter any table to sapdba;
grant alter any index to sapdba;
grant alter any procedure to sapdba;
grant analyze any to sapdba;
grant analyze any dictionary to sapdba;
grant execute any procedure to sapdba;
grant gather_system_statistics to sapdba;
grant create public synonym to sapdba;
grant drop public synonym to sapdba;
grant create job to sapdba;

column dummy noprint new_value User
select :Owner dummy from dual;

grant ALL on &User..SDBAH to sapdba;
grant ALL on &User..SDBAD to sapdba;
grant ALL on &User..DBAML to sapdba;
grant ALL on &User..DBARCL to sapdba;
grant ALL on &User..DBAFID to sapdba;
grant ALL on &User..DBAEXTL to sapdba;
grant ALL on &User..DBAREOL to sapdba;
grant ALL on &User..DBABARL to sapdba;
grant ALL on &User..DBADFL to sapdba;
grant ALL on &User..DBAOPTL to sapdba;
grant ALL on &User..DBASPAL to sapdba;
grant ALL on &User..DBABD to sapdba;
grant ALL on &User..DBABL to sapdba;
grant ALL on &User..DBATL to sapdba;
grant ALL on &User..DBAOBJL to sapdba;
grant ALL on &User..DBAPHAL to sapdba;
grant ALL on &User..DBAGRP to sapdba;
grant ALL on &User..DBAERR to sapdba;
grant ALL on &User..DBATRIAL to sapdba;
grant ALL on &User..DBSTATC to sapdba;
grant ALL on &User..DBSTATTORA to sapdba;
grant ALL on &User..DBSTATIORA to sapdba;
grant ALL on &User..DBSTATHORA to sapdba;
grant ALL on &User..DBSTAIHORA to sapdba;
grant ALL on &User..DBMSGORA to sapdba;
grant ALL on &User..DBCHECKORA to sapdba;
grant ALL on &User..MLICHECK to sapdba;
grant SELECT on &User..TGORA to sapdba;
grant SELECT on &User..IGORA to sapdba;
grant SELECT on &User..TSORA to sapdba;
grant SELECT on &User..TAORA to sapdba;
grant SELECT on &User..IAORA to sapdba;
grant SELECT on &User..SVERS to sapdba;
grant SELECT on &User..CVERS to sapdba;
grant SELECT on &User..DD02L to sapdba;
grant SELECT on &User..DD09L to sapdba;
grant SELECT on &User..DDNTT to sapdba;
grant SELECT on &User..DDART to sapdba;
grant SELECT on &User..DARTT to sapdba;
grant SELECT on &User..DBCHK to sapdba;
grant SELECT on &User..DBDIFF to sapdba;

declare

Curs		INTEGER;
Statement	VARCHAR2(128);
RetWert		NUMBER;
table_not_found EXCEPTION;

pragma exception_init (table_not_found, -942);

begin

Curs := dbms_sql.open_cursor;

begin
 Statement := 'grant ALL on &User..SAPLIKEY to sapdba';
 dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
 RetWert := dbms_sql.execute(Curs);
exception
 when table_not_found then
 NULL;
end;

begin
 Statement := 'grant SELECT on &User..RSNSPACE to sapdba';
 dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
 RetWert := dbms_sql.execute(Curs);
exception
 when table_not_found then
 NULL;
end;

begin
 Statement := 'grant SELECT on &User..RSPSPACE to sapdba';
 dbms_sql.parse(Curs, Statement, DBMS_SQL.NATIVE);
 RetWert := dbms_sql.execute(Curs);
exception
 when table_not_found then
 NULL;
end;

dbms_sql.close_cursor(Curs);

end; -- procedure
/

exit;


