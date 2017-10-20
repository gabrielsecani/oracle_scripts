WHENEVER SQLERROR EXIT SQL.SQLCODE
connect / as sysdba
set feedback off
spool oradbusr.log
set serverout on
set termout on
--set echo on;

/*----------------------------------------------------------------------------------*/
/*  oradbusr.sql creates the Oracle Default Users for Operating                     */
/*  system based DB authentication                                                  */
/*                                                                                  */
/*  usage:                                                                          */
/*   UNIX: sqlplus /NOLOG @oradbusr.sql SCHEMAOWNER UNIX SAP_SID x                */
/*   NT:   sqlplus /nolog @oradbusr.sql SCHEMAOWNER NT COMPUTER|DOMAIN SAP_SID    */
/*                                                                                  */
/*  The SCHEMAOWNER is either SAPR3 or has to start with SAP                        */
/*  followed by the three digit schema id (example: SAPPRD).                        */
/*  Specify DOMAIN, if you use Oracle 8.1.5 or higher                               */
/*  On NT the Userdomain (DOMAIN) or Computername (COMPUTER)                        */
/*  must be specified depending on wether you are using a domain or                 */
/*  a local account.                                                                */
/*  On Unix x is a dummy paramter and may e. g. be set to  X                        */ 
/*----------------------------------------------------------------------------------*/

VARIABLE sPrefix  varchar2(100)
VARIABLE sSchemaId varchar2(100);
VARIABLE sSapSid varchar2(100);
VARIABLE sVersion varchar2(100);
VARIABLE sDomain varchar2(100);
VARIABLE sR3user varchar2(100);
VARIABLE sSvcuser varchar2(100);
VARIABLE bONNT    number;
VARIABLE bSCHEMA  number;
VARIABLE sSchema  varchar2(100);
VARIABLE cur number;
VARIABLE r number;
VARIABLE stmt varchar2(200);
VARIABLE errtxt1 varchar2(200);

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
		raise emergency;
      end if;
   else
		:bSCHEMA := 1;
		:sSchema := upper('&&1');
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
		end if;
   end if;
end;
end;
/
set termout on

begin
   declare 
	sPrefix varchar2(100);
    nSchemaLen number;
begin

   select version into :sVersion from v$instance;
   select value into sPrefix from v$parameter where name='os_authent_prefix';

   if :bSCHEMA = 1 then
		:sSchemaId := substr(:sSchema,4,3);
   else
		:sSchemaId := 'R3';
   end if;

   sPrefix := upper(sPrefix);

   if :bONNT = 1 then
      if :sVersion > '8.1.0.0.0' then
        :sR3user := sPrefix || :sDomain || '\' || :sSapSid || 'ADM';
		:sSvcuser := sPrefix || :sDomain || '\' || 'SAPSERVICE' || :sSapSid;
      else
        :sR3user := sPrefix || :sSapSid || 'ADM';
		:sSvcuser := sPrefix || 'SAPSERVICE' || :sSapSid;
      end if;
   else
	:sR3user := sPrefix || :sSapSid || 'ADM';
   end if;

   dbms_output.put_line('using following Parameters: ');
   dbms_output.put_line('.');
   dbms_output.put_line('.  Oracle Version:                     '||:sVersion);
   dbms_output.put_line('.  Parametervalue os_authent_prefix:   '||sPrefix);
   dbms_output.put_line('.  Schema Id:                          '||:sSchemaId);
   dbms_output.put_line('.  Database User (Schema):             '||:sSchema); 
   dbms_output.put_line('.  SAP R/3 Administrator:              '||:sR3user);
   if :bONNT = 1 then
   dbms_output.put_line('.  SAP R/3 Serviceuser:                '||:sSvcuser);
   end if;
   dbms_output.put_line('.');
end;
end;
/

/* --- Delete old Definitions, needed in homogenious System ----*/
/*     copies by database copy                              ----*/

/* --- Drop public Synonyms on SAPUSER - each Schema has to use its own Synonym ---*/
begin
   declare 
	nSyn number;
begin
   :cur := dbms_sql.open_cursor;
   nSyn := 1;
   select count(*) into nSyn from dba_synonyms where synonym_name='SAPUSER' 
			and owner = 'PUBLIC';
   if nSyn > 0 then
     :stmt := 'drop public synonym SAPUSER';
     dbms_sql.parse(:cur, :stmt, DBMS_SQL.NATIVE);
     :r := dbms_sql.execute(:cur);
	 dbms_output.put_line('the Public synonym SAPUSER was dropped!');
	 dbms_output.put_line('please run this script also for the other');
	 dbms_output.put_line('SAP Schema owners (e.g. SAPR3)');
   end if;
   EXCEPTION
     when others then
		dbms_sql.close_cursor(:cur);
		:errtxt1 := 'error dropping synonym SAPUSER';
		dbms_output.put_line(:errtxt1);
	RAISE;
end;
end;
/
/* --- Drop public Synonyms on SAPUSER - each Schema has to use its own Synonym ---*/
begin
   declare 
	nSyn number;
begin
   :cur := dbms_sql.open_cursor;
   nSyn := 1;
   select count(*) into nSyn from dba_synonyms where synonym_name='SAPUSER' 
			and owner = :sSvcuser;
   if nSyn > 0 then
     :stmt := 'drop synonym "' || :sSvcuser || '".SAPUSER';
     dbms_sql.parse(:cur, :stmt, DBMS_SQL.NATIVE);
     :r := dbms_sql.execute(:cur);
   end if;
   EXCEPTION
     when others then
		dbms_sql.close_cursor(:cur);
		:errtxt1 := 'error dropping synonym "'||:sSvcuser||'".SAPUSER';
		dbms_output.put_line(:errtxt1);
	RAISE;
end;
end;
/
/* --- Drop Old Tables --- */
begin
   DECLARE
      Cursor C1 is Select owner from dba_tables where table_name = 'SAPUSER' and 
	      owner = :sR3user;
      c number;
      r number;   
      s varchar2(299);
begin
   begin
      c := dbms_sql.open_cursor;
      FOR c1_rec IN c1 LOOP
          s := '"' || c1_rec.owner || '".SAPUSER';
          dbms_sql.parse(c, 'Drop table "' || c1_rec.owner || '".SAPUSER', DBMS_SQL.NATIVE);
          r := dbms_sql.execute(c);
      END LOOP;
      dbms_sql.close_cursor(c);
      EXCEPTION
          when others then
             dbms_sql.close_cursor(c);
             dbms_output.put_line('error deleting table: '||s||' missing privileges or wrong user!');
	     RAISE;
   end;
   EXCEPTION
      when others then
      RAISE;
end;
end;
/
/*--- Drop old users ---*/
begin
   DECLARE
	c number;
	r number;
	s varchar2(60);
    v_counter   integer;
	statement   varchar2(128);
	v_pass      varchar2(30);
begin
   begin
	s := :sR3user;
	c := dbms_sql.open_cursor;

/*--- Drop User OPS$sidADM ---*/
	dbms_sql.parse(c, 'Drop user "' || s || '"', DBMS_SQL.NATIVE);
	r := dbms_sql.execute(c);
	dbms_sql.close_cursor(c);
	EXCEPTION
	   when others then
		if sqlcode = -1917 or sqlcode = -1918 then
 		 s := 'dummy';
		else
		 dbms_output.put_line('unable to delete user: '||s);
		 RAISE;
	 	end if;
   end;

/*--- NT only drop old User OPS$SAPSERVICEsid ---*/
   begin
	if (:boNNT = 1) then
	   s := :sSvcuser;
	   c := dbms_sql.open_cursor;

	   dbms_sql.parse(c, 'Drop user "' || s || '"', DBMS_SQL.NATIVE);
 	   r := dbms_sql.execute(c);
	   dbms_sql.close_cursor(c);
	end if;
	EXCEPTION
	   when others then
		if sqlcode = -1917 or sqlcode = -1918 then
		 s := 'dummy';
		else
		 dbms_output.put_line('unable to delete user: '||s);
		 RAISE;
	 	end if;
   end;
/*---   create user OPS$sidadm --- */
   begin
        s := :sR3user;
        c := dbms_sql.open_cursor;
        dbms_sql.parse(c, 'Create user "' || s || '" identified by temp temporary tablespace psaptemp', DBMS_SQL.NATIVE);
        r := dbms_sql.execute(c);
	        dbms_sql.close_cursor(c);
        EXCEPTION
           when others then
	        dbms_output.put_line('unable to create user: '||s);
	        RAISE;
   end;

/*---   create user sapr3 --- */
/* create user sapr3 identified by sap                     */
/* if user already exists, check if it was given DBA role  */
/* if yes, revoke role DBA from sapr3                      */
   begin
	c := dbms_sql.open_cursor;
    statement := 'create user ' || :sSchema || ' identified by sap temporary tablespace psaptemp';
    dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
    r := dbms_sql.execute(c);
   exception
    when others then
    select count(*) into v_counter from dba_role_privs where grantee = s and granted_role ='DBA';
     if v_counter > 0 then
      statement := 'revoke dba from  ' || :sSchema;
      dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
      r := dbms_sql.execute(c);
     end if;
   end;
/* assign default tablespace to schema owner                      */
	begin
	 if :bSchema = 0 then
		statement := 'alter user ' || :sSchema || ' default tablespace psapuser1d';
	 else
		statement := 'alter user ' || :sSchema || ' default tablespace psap'||:sSchemaId||'USR';
	 end if;
	 dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
	 r := dbms_sql.execute(c);
	exception
	 when others then
	   dbms_output.put_line('unable to assign default tablespace to user: '||:sSchema);
       RAISE;
	end;


/* assign temporary tablespace to schema owner                    */
	begin
	 statement := 'alter user ' || :sSchema || ' temporary tablespace psaptemp';
	 dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
	 r := dbms_sql.execute(c);
	exception
	 when others then
	   dbms_output.put_line('unable to assign temporary tablespace psaptemp to user: '|| :sSchema);
       RAISE;
	end;

/* grant privileges to schema owner                               */
	statement := 'grant connect, resource, select_catalog_role, unlimited tablespace to ' || :sSchema;
	dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
	r := dbms_sql.execute(c);


/*---   alter user system and sys --- */
/* assign temporary tablespace to system                    */
	begin
	 s := 'system';
	 statement := 'alter user ' || s || ' temporary tablespace psaptemp';
	 dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
	 r := dbms_sql.execute(c);
	exception
	 when others then
	   dbms_output.put_line('unable to assign temporary tablespace psaptemp to user: '||s);
       RAISE;
	end;

/* assign temporary tablespace to sys                       */
	begin
	 s := 'sys';
	 statement := 'alter user ' || s || ' temporary tablespace psaptemp';
	 dbms_sql.parse(c, statement, DBMS_SQL.NATIVE);
	 r := dbms_sql.execute(c);
	exception
	 when others then
	   dbms_output.put_line('unable to assign temporary tablespace psaptemp to user: '||s);
       RAISE;
	end;


/*--- NT only: create SAP Service OPS$ user  --- */
	begin
	  if :bONNT = 1 then
		s := :sSvcuser;
		c := dbms_sql.open_cursor;
		dbms_sql.parse(c, 'Create user "' || s || '" identified externally temporary tablespace psaptemp', DBMS_SQL.NATIVE);
		r := dbms_sql.execute(c);
		dbms_sql.close_cursor(c);
	  end if;
		EXCEPTION
		   when others then
				dbms_output.put_line('unable to create user: '||s);
			RAISE;
	end;


/*---  Create SAPDBA role ---*/
	begin
	  c := dbms_sql.open_cursor;
	  dbms_sql.parse(c, 'create role sapdba', DBMS_SQL.NATIVE);
	  r := dbms_sql.execute(c);
	  dbms_sql.close_cursor(c);
	  EXCEPTION
	when others then
	   if sqlcode = -1921 then
			   s := 'dummy';
		   else
			   dbms_output.put_line('cannot create SAPDBA role: ');
		   RAISE;
		   end if;
	end;

/*---   grants for OPS$sidADM --- */
	begin
		s := :sR3user;
		c := dbms_sql.open_cursor;

		dbms_sql.parse(c, 'grant connect, resource, sapdba to  "' || s || '"', DBMS_SQL.NATIVE);
		r := dbms_sql.execute(c);
		dbms_sql.close_cursor(c);
	EXCEPTION
		when others then
 		  dbms_output.put_line('unable to grant connect, resource, sapdba to: '||s);
		  RAISE;
	end;

/*---   NT only: grants for OPS$SAPSERVICEsid --- */
   begin
     if :bONNT = 1 then
        s := :sSvcuser;
        c := dbms_sql.open_cursor;

        dbms_sql.parse(c, 'grant connect, resource, sapdba to  "' || s || '"', DBMS_SQL.NATIVE);
        r := dbms_sql.execute(c);
        dbms_sql.close_cursor(c);
     end if;
     EXCEPTION
	when others then
 	   dbms_output.put_line('unable to grant connect, resource to: '||s);
	   RAISE;
   end;

/*---  Create table sapuser ---*/
   begin
     c := dbms_sql.open_cursor;

     dbms_sql.parse(c, 'create table "' || :sR3user || 
          '".SAPUSER (userid varchar2(255), passwd varchar2(255))', 
          DBMS_SQL.NATIVE);
     r := dbms_sql.execute(c);
     dbms_sql.close_cursor(c);
     EXCEPTION
	when others then
 	   dbms_output.put_line('unable to create table SAPUSER');
	   RAISE;
   end;

   begin
     if :bONNT = 1 then
		 c := dbms_sql.open_cursor;

		 dbms_sql.parse(c, 'create synonym "'||:sSvcuser|| '".sapuser for "' || :sR3user || '".SAPUSER', 
			  DBMS_SQL.NATIVE);
		 r := dbms_sql.execute(c);
		 dbms_sql.close_cursor(c);
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
spool cocon.sql
begin
    DECLARE
        sHelp varchar2(200);
begin
    dbms_output.put_line('connect ' || :sR3user || '/temp');
end;
end;
/
spool off
set termout on
WHENEVER OSERROR CONTINUE
@cocon.sql
WHENEVER OSERROR EXIT FAILURE
begin
  DECLARE
      c number;
      r number;
  begin
    if :bONNT = 1 then
      c := dbms_sql.open_cursor();

      dbms_sql.parse(c, 'grant select, update, insert on sapuser to "' || :sSvcuser || '"', DBMS_SQL.NATIVE);
      r := dbms_sql.execute(c);
      dbms_sql.close_cursor(c);
    end if;
      EXCEPTION
        when others then
        dbms_output.put_line('unable to grant rights on sapuser');
        RAISE;
  end;
end;
/
WHENEVER OSERROR CONTINUE
connect / as sysdba
WHENEVER OSERROR EXIT FAILURE
begin
  DECLARE
      c number;
      r number;
  begin
      c := dbms_sql.open_cursor();

      dbms_sql.parse(c, 'alter user "' || :sR3user || '" identified externally', DBMS_SQL.NATIVE);
      r := dbms_sql.execute(c);
      dbms_sql.close_cursor(c);
      EXCEPTION
        when others then
        dbms_output.put_line('unable to grant rights on sapuser');
        RAISE;
  end;
end;
/
EXIT SUCCESS

