WHENEVER SQLERROR EXIT SQL.SQLCODE
connect / as sysdba
set feedback off
set timing off
spool oradbusr.log
set serverout on
set termout on
set echo on;

/*----------------------------------------------------------------------------------*/
/*  oradbusr.sql creates the Oracle Default Users for Operating                     */
/*  system based DB authentication                                                  */
/*  @(#) $Id: //inst/inst_scripts/lmts_008_REL/tpls/ora/ORADBUSR.SQL#2 $ */
/*                                                                                  */
/*  usage:                                                                          */
/*   UNIX: sqlplus /NOLOG @oradbusr.sql SCHEMAOWNER UNIX SAP_SID x S                */
/*   NT:   sqlplus /nolog @oradbusr.sql SCHEMAOWNER NT COMPUTER|DOMAIN SAP_SID S    */
/*                                                                                  */
/*  The SCHEMAOWNER is either SAPR3 or has to start with SAP                        */
/*  followed by the three digit schema id (example: SAPPRD).                        */
/*  Specify DOMAIN, if you use Oracle 8.1.5 or higher                               */
/*  On NT the Userdomain (DOMAIN) or Computername (COMPUTER)                        */
/*  must be specified depending on wether you are using a domain or                 */
/*  a local account.                                                                */
/*  On Unix x should be set to A for ASM or X for dummy                             */ 
/*  S = 1 for SAPUSER connect or 0 for ABAP Secure Store Connect                    */ 
/*----------------------------------------------------------------------------------*/

VARIABLE sPrefix  varchar2(100)
VARIABLE sSchemaId varchar2(100);
VARIABLE sSapSid varchar2(100);
VARIABLE sIsASM varchar2(3);
VARIABLE sIsSapuser number;
VARIABLE sDbSid varchar2(100);
VARIABLE sVersion varchar2(100);
VARIABLE sDomain varchar2(100);
VARIABLE sR3user varchar2(100);
VARIABLE sDbuser varchar2(100);
VARIABLE sDbuserOra varchar2(100);
VARIABLE sSvcuser varchar2(100);
VARIABLE bONNT    number;
VARIABLE bSCHEMA  number;
VARIABLE sSchema  varchar2(100);
VARIABLE cur number;
VARIABLE r number;
VARIABLE stmt varchar2(200);
VARIABLE errtxt1 varchar2(200);

VARIABLE sUserTsp varchar2(30);
VARIABLE sTempTsp varchar2(30);

WHENEVER OSERROR EXIT FAILURE

/* ---  initialization ---*/
/* SID, Oracle DB Version, Prefix, Domainname, number of sapuser tables */
begin
declare 
  emergency EXCEPTION;

begin
  if length('&&1') = 5 then
    if substr(upper('&&1'),1,5) = 'SAPR3' then
      :bSCHEMA := 0;
      :sSchema := 'SAPR3';
      :sSchemaId := 'SR3';
      if upper('&&2') = 'NT' then
        :bONNT := 1;
      else
	:bONNT := 0;
      end if;

      if :bONNT = 1 then
	:sDomain := upper('&&3');
        :sSapSid := upper('&&4');
      else
        :sSapSid := upper('&&3');                        
        :sIsASM  := upper('&&4');
      end if;
    else
      dbms_output.put_line('-');
      dbms_output.put_line('-');
      dbms_output.put_line('---------------------------------------------------------------------');
      dbms_output.put_line('not supported:');
      dbms_output.put_line('Schemaowner has to be SAPR3 or SAP<SID> where <SID>');
      dbms_output.put_line('has to be a three digit Identifier starting with a character');
      dbms_output.put_line('---------------------------------------------------------------------');
      dbms_output.put_line('-');
      dbms_output.put_line('-');
      RAISE_APPLICATION_ERROR (-20001, 'wrong Schemaowner');
    end if;
  else
    :bSCHEMA := 1;
    :sSchema := upper('&&1');
    :sSchemaId := substr(:sSchema,4,3);
    if upper('&&2') = 'NT' then
      :bONNT := 1;
    else
      :bONNT := 0;
    end if;

    if :bONNT = 1 then
      :sDomain := upper('&&3');
      :sSapSid := upper('&&4');
    else
      :sSapSid := upper('&&3');                        
      :sIsASM  := upper('&&4');
    end if;
  end if;
  :sIsSapuser := '&&5';
end;
end;
/
set termout on

begin
  declare 
    nSchemaLen number;
begin

  select version into :sVersion from v$instance;
  select value into :sPrefix from v$parameter where name='os_authent_prefix';
  select name into :sDbSid from v$database;


  :sPrefix := upper(:sPrefix);

  if :bONNT = 1 then
    if substr(:sVersion,1,1) = '8' then
      :sR3user := :sPrefix || :sSapSid || 'ADM';
      :sSvcuser := :sPrefix || 'SAPSERVICE' || :sSapSid;
    else
        :sR3user := :sPrefix || :sDomain || '\' || :sSapSid || 'ADM';
	:sSvcuser := :sPrefix || :sDomain || '\' || 'SAPSERVICE' || :sSapSid;
    end if;
    if length(:sSvcuser) > 30 then
      dbms_output.put_line('Service username too long: max length is 30          '||:sSvcuser);
      RAISE_APPLICATION_ERROR (-20000, 'Service username too long: max length is 30');
    end if;
  else
    :sR3user  := :sPrefix || :sSapSid || 'ADM';
    :sDbuser  := :sPrefix || 'ORA' || :sDbSid;
    :sDbuserOra  := :sPrefix || 'ORA' || 'CLE';
    :sSvcuser := :sPrefix || 'SAPSERVICE' || :sSapSid;
  end if;

/* set default user and temp tablespace */
  :sUserTsp := 'PSAP' || :sSchemaId || 'USR'; 
  :sTempTsp := 'PSAPTEMP'; 
  
  dbms_output.put_line('using following Parameters: ');
  dbms_output.put_line('.');
  dbms_output.put_line('.  Oracle Version:                     '||:sVersion);
  dbms_output.put_line('.  Parametervalue os_authent_prefix:   '||:sPrefix);
  dbms_output.put_line('.  Schema Id:                          '||:sSchemaId);
  dbms_output.put_line('.  Database User (Schema):             '||:sSchema); 
  dbms_output.put_line('.  SAP R/3 Administrator:              '||:sR3user);
  dbms_output.put_line('.  SAP R/3 Serviceuser:                '||:sSvcuser);
  dbms_output.put_line('.  ASM Parameter:                      '||:sIsASM);
  dbms_output.put_line('.  Create SAPUSER env:                 '||:sIsSapuser);
  if :bONNT = 1 then
  dbms_output.put_line('.  Domain/Host:                        '||:sDomain);
end if;
   dbms_output.put_line('.');
end;
end;
/

/* --- Delete old Definitions, needed in homogenious System ----*/
/*     copies bnym sap$histgrm';
      c := dbms_sql.open_cursor;
      dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
      r := dbms_sql.execute(c);
      dbms_sql.close_cursor(c);
    exception
      when others then
        dbms_output.put_line('');
    end;
    statement := 'create public synonym sap$histgrm for sap_$histgrm';
    c := dbms_sql.open_cursor;
    dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
    r := dbms_sql.execute(c);
    statement := 'grant select on sap$histgrm to public';
    dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
    r := dbms_sql.execute(c);
    dbms_sql.close_cursor(c);



/*---   alter user system and sys --- */
/* assign temporary tablespace to system                    */
    begin
      s := 'system';
      statement := 'alter user ' || s || ' temporary tablespace ' || :sTempTsp;
      c := dbms_sql.open_cursor;
      dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
      r := dbms_sql.execute(c);
      dbms_sql.close_cursor(c);
      dbms_output.put_line('ALTER user done: ' || s);
      exception
        when others then
          dbms_output.put_line('unable to assign temporary tablespace psaptemp to user: '||s);
          RAISE;
    end;

/* assign temporary tablespace to sys                       */
    begin
      s := 'sys';
      statement := 'alter user ' || s || ' temporary tablespace ' || :sTempTsp;
      c := dbms_sql.open_cursor;
      dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
      r := dbms_sql.execute(c);
      dbms_sql.close_cursor(c);
      dbms_output.put_line('ALTER user done: ' || s);
      exception
        when others then
          dbms_output.put_line('unable to assign temporary tablespace psaptemp to user: '||s);
          RAISE;
    end;


/*--- NT and UNIX: create SAP Service OPS$ user  --- */
    begin
      s := :sSvcuser;
      c := dbms_sql.open_cursor;
      statement := 'Create user "' || s || '" identified externally default tablespace ' || :sUserTsp || ' temporary tablespace ' || :sTempTsp;
      dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
      r := dbms_sql.execute(c);
      dbms_sql.close_cursor(c);
      dbms_output.put_line('CREATE user done: ' || s);
      EXCEPTION
        when others then
          dbms_output.put_line('unable to create user: '||s);
          RAISE;
    end;



/*---   UNIX only: grants for OPS$ORA<dbsid> --- <dbsid = cle for ASM */
    begin
      if :bONNT = 0 then
        if :sIsASM = 'A' then
          s := :sDbuserOra;
        else
          s := :sDbuser;
        end if;
        c := dbms_sql.open_cursor;
        statement := 'grant sapdba, unlimited tablespace to  "' || s || '"';
        dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
        r := dbms_sql.execute(c);
        dbms_sql.close_cursor(c);
        dbms_output.put_line('GRANT done: '|| s);
      end if;
      EXCEPTION
        when others then
          dbms_output.put_line('unable to grant sapdba, unlimited tablespace to: '||s);
          RAISE;
    end;

/*---   grants for OPS$sidADM --- */
    begin
      s := :sR3user;
      c := dbms_sql.open_cursor;
      statement := 'grant create session, sapdba, unlimited tablespace to  "' || s || '"';
      dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
      r := dbms_sql.execute(c);
      dbms_sql.close_cursor(c);
      dbms_output.put_line('GRANT done: '|| s);
      EXCEPTION
        when others then
        dbms_output.put_line('unable to grant sapdba, unlimited tablespace to: '||s);
        RAISE;
    end;

/*---   NT and UNIX: grants for OPS$SAPSERVICEsid --- */
    begin
      s := :sSvcuser;
      c := dbms_sql.open_cursor;
      statement := 'grant sapdba, unlimited tablespace to  "' || s || '"';
      dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
      r := dbms_sql.execute(c);
      dbms_sql.close_cursor(c);
      dbms_output.put_line('GRANT done: ' || s);
      EXCEPTION
        when others then
          dbms_output.put_line('unable to grant sapdba, unlimited tablespace to: '||s);
          RAISE;
    end;

/*---  Create table sapuser ---*/
    begin
      if :sIsSapuser = 1 then
        c := dbms_sql.open_cursor;
        statement := 'create table "' || :sR3user || '".SAPUSER (userid varchar2(255), passwd varchar2(255))';
        dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
        r := dbms_sql.execute(c);
        dbms_sql.close_cursor(c);
        dbms_output.put_line('CREATE table done:' || :sR3user || '.SAPUSER');
      end if;
      EXCEPTION
        when others then
          dbms_output.put_line('unable to create table SAPUSER');
          RAISE;
    end;

    begin
      if :sIsSapuser = 1 then
        c := dbms_sql.open_cursor;
        statement := 'create synonym "'||:sSvcuser|| '".sapuser for "' || :sR3user || '".SAPUSER';
        dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
        r := dbms_sql.execute(c);
        dbms_sql.close_cursor(c);
        dbms_output.put_line('CREATE synonym done: ' || :sSvcuser || '.sapuser');
      end if;
      EXCEPTION
        when others then
          dbms_output.put_line('unable to create public synonym SAPUSER');
          RAISE;
    end;
  end;
end;
/
set echo off
set termout off
set feedback off
set serverout on
set timing off
set time off
set autotrace off
/* grant now with sysdba user -- cocon.sql not needed any longer */
/*
spool cocon.sql
begin
  DECLARE
    sHelp varchar2(200);
  begin
    dbms_output.put_line('connect ' || :sR3user || '/temp');
  end;
end;
/
set termout on
WHENEVER OSERROR CONTINUE
spool off 
@cocon.sql
WHENEVER OSERROR EXIT FAILURE
*/
begin
  DECLARE
    c number;
    r number;
    statement varchar2(128);
  begin
    if :sIsSapuser = 1 then
      c := dbms_sql.open_cursor();
      statement := 'grant select, update, insert on "' || :sR3user || '".SAPUSER to "' || :sSvcuser || '"';
      dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
      r := dbms_sql.execute(c);
      dbms_sql.close_cursor(c);
      dbms_output.put_line('GRANT rights done: ' ||  :sR3user || '.SAPUSER');
    end if;
    EXCEPTION
      when others then
        dbms_output.put_line('unable to grant rights on sapuser');
        RAISE;
  end;
end;
/
begin
  DECLARE
    c number;
    r number;
    statement varchar2(128);
  begin
    c := dbms_sql.open_cursor();
    statement := 'alter user "' || :sR3user || '" identified externally';
    dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
    r := dbms_sql.execute(c);
    dbms_sql.close_cursor(c);
    dbms_output.put_line('ALTER user done: ' || :sR3user);
    EXCEPTION
      when others then
      dbms_output.put_line('unable to alter user ' || :sR3user);
      RAISE;
  end;
end;
/
EXIT SUCCESS

