https://dbatricksworld.com/steps-to-configure-oracle-11g-data-guard-physical-standby-data-guard-part-i/
solman: 8000028170

-- cria pfile no $ORACLE_HOME/dbs/initXXXX.ora  XXXX = SID = eq0
create pfile from spfile;
-- abrir initeq0.ora para trocar/adicionar db_unique_name='eq0A'

--configura 
ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(eq0A,eq0B)';


-- Enable Forced Logging

ALTER DATABASE FORCE LOGGING;
 Configure the Primary Database to Receive Redo Data****

-- Set Primary Database Initialization Parameters

DB_NAME=eq0
DB_UNIQUE_NAME=eq0
LOG_ARCHIVE_CONFIG='DG_CONFIG=(eq0A,eq0B)'
CONTROL_FILES='/arch1/eq0/control1.ctl', '/arch2/eq0/control2.ctl'
LOG_ARCHIVE_DEST_1='LOCATION=/arch1/eq0/ VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=eq0A'
LOG_ARCHIVE_DEST_2='SERVICE=eq0 ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=eq0B'
LOG_ARCHIVE_DEST_STATE_1=ENABLE
LOG_ARCHIVE_DEST_STATE_2=ENABLE
REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE
LOG_ARCHIVE_FORMAT=%t_%s_%r.arc

eq0A
ALTER SYSTEM SET log_archive_config='DG_CONFIG=(EQ0A,EQ0B)' scope=both;
ALTER SYSTEM SET log_archive_dest_1='LOCATION=+ARCH/eq0/oraarch VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=eq0A' scope=both;
ALTER SYSTEM SET log_archive_dest_2='SERVICE=eq0B ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=eq0B' scope=both;

eq0B
ALTER SYSTEM SET log_archive_config='DG_CONFIG=(eq0A,eq0B)' scope=both;
ALTER SYSTEM SET log_archive_dest_1='LOCATION=+ARCH/eq0/oraarch VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=eq0B' scope=both;
ALTER SYSTEM SET log_archive_dest_2='SERVICE=EQ0A ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=EQ0A' scope=both;

ALTER SYSTEM SET log_archive_dest_2='SERVICE=EQ0B ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=EQ0B' scope=both;

ALTER SYSTEM SET log_archive_dest_state_2=reset;


alter system set STANDBY_FILE_MANAGEMENT='AUTO'  scope=both;

alter system set FAL_SERVER='eq0A'  scope=both;
alter system set FAL_SERVER='eq0B'  scope=both;

alter system set FAL_CLIENT='EQ0B'  scope=both;

--Primary Database: Standby Role Initialization Parameters  
FAL_SERVER=boston
DB_FILE_NAME_CONVERT='boston','chicago'
LOG_FILE_NAME_CONVERT=
 '/arch1/boston/','/arch1/chicago/','/arch2/boston/','/arch2/chicago/' 
STANDBY_FILE_MANAGEMENT=AUTO

### RESTART 
shutdown immediate

# inicia usando 
startup pfile="/oracle/eq0/11204/dbs/initeq0.ora";
startup pfile="/oracle/eq0/11204/dbs/initeq0B.ora";


# cria um control file para subir instancia do standby
alter database create standby controlfile as '/migracao/backup/standbyctrl.ctl';
create pfile='/migracao/backup/initeq0B.ora' from spfile;
create pfile='/home/oracle/initeq0B.ora' from spfile;

#criar arquivo de senha
orapwd file=$ORACLE_HOME/dbs/orapwED0 password=DRSAP01ED0 entries=100 force=y ignorecase=Y

select * from v$pwfile_users;
orapwd file=$ORACLE_HOME/dbs/orapwEP0 password=DRSAP01EP0 entries=100 force=y ignorecase=Y
scp orapwdED0 root@sapdev2:/oracle/eq011204/dbs/
chown oracle:oinstall /oracle/eq011204/dbs/orapwdED0

'/oracle/eq0/11204/dbs/stdby.ctl'
*.control_files='+DATA/eq0/cntrleq0.ctl','+ARCH/eq0/cntrleq0.ctl'

alter database copy controlfile to '+DATA/eq0/controlfileeq0.ctl';

alter system set control_files='+DATA/eq0/controlfileeq0.ctl','+ARCH/eq0/controlfileeq0.ctl' scope=both sid='*';


PAUSE on STEP 14;


create user sum identified by sum123;
grant dba to sum;

restore controlfile to '+arch' from '/migracao/initeq0B.ora';

/migracao/standbyctrl.ctl
/migracao/initeq0B.ora

/oracle/eq0/11204/dbs/stdby.ctl

*.control_files='+DATA/eq0/cntrleq0.dbf','+ARCH/eq0/cntrleq0.dbf'


startup pfile="/oracle/eq0/11204/dbs/initeq0.ora" nomount;
show parameter control

--Start the database:
STARTUP NOMOUNT;

--Mount the standby database:
ALTER DATABASE MOUNT STANDBY DATABASE;

--Start the managed recovery operation:
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;


scp orapwdED0 root@sapdev2:/oracle/eq011204/dbs/
chown oracle:oinstall /oracle/eq011204/dbs/orapwdED0


alter database backup controlfile to trace as '/migracao/ctrlfilea.txt';
alter database backup controlfile to trace as '/migracao/ctrlfilea.txt';


sqlplus sys/drSAP01eq0@eq0A as sysdba
sqlplus sys/drSAP01eq0@eq0B as sysdba

STARTUP NOMOUNT

sqlplus sys/drSAP01eq0@eq0B as sysdba

rman target sys/drSAP01eq0@eq0A nocatalog
connect target sys/drSAP01eq0@eq0A
connect auxiliary /

STARTUP CLONE NOMOUNT FORCE;
DUPLICATE TARGET DATABASE TO AUX;

 lsnrctl stop; lsnrctl start;sleep 5;
 lsnrctl status


sqlplus SYS/drSAP01eq0@eq0 as sysdba
sqlplus SYS/drSAP01eq0@eq0A as sysdba 
sqlplus SYS/drSAP01eq0@eq0B as sysdba 

shutdown immediate;

startup nomount;

rman TARGET SYS/drSAP01eq0@eq0A AUXILIARY SYS/drSAP01eq0@eq0B

CONNECT AUXILIARY SYS/drSAP01eq0@eq0
CONNECT AUXILIARY SYS/drSAP01eq0@eq0B
CONNECT TARGET SYS/drSAP01eq0@eq0A

rman TARGET SYS/drSAP01EQ0@EQ0B AUXILIARY SYS/drSAP01EQ0@EQ0A

rman TARGET SYS/drSAP01EQ0@EQ0A AUXILIARY SYS/drSAP01EQ0@EQ0B
rman TARGET SYS/drSAP01ED0@ED0A AUXILIARY / SYS/drSAP01ED0@ED0B

run{
ALLOCATE AUXILIARY CHANNEL cb1 DEVICE TYPE DISK;
ALLOCATE CHANNEL ca1 DEVICE TYPE DISK;
DUPLICATE TARGET DATABASE
  FOR STANDBY
  FROM ACTIVE DATABASE 
  DORECOVER
  NOFILENAMECHECK;
}



duplicate target database from active database using COMPRESSED BACKUPSET;


restore database;
recover database;


alter system set LOCAL_LISTENER='(ADDRESS = (PROTOCOL = TCP)(HOST = sapdev2)(PORT = 1522))' scope=both;


###
criar no eq0 B os mesmos logfiles


ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=MANUAL;

ALTER DATABASE ADD LOGFILE GROUP 1 ('+ARCH/eq0/onlinelog/group_1B.dbf', '+DATA/eq0/onlinelog/group_1A.dbf') size 200M REUSE;
ALTER DATABASE ADD LOGFILE GROUP 2 ('+ARCH/eq0/onlinelog/group_2B.dbf', '+DATA/eq0/onlinelog/group_2A.dbf') SIZE 200M reuse;
ALTER DATABASE ADD LOGFILE GROUP 3 ('+ARCH/eq0/onlinelog/group_3B.dbf', '+DATA/eq0/onlinelog/group_3A.dbf') SIZE 200M reuse;
ALTER DATABASE ADD LOGFILE GROUP 4 ('+ARCH/eq0/onlinelog/group_4B.dbf', '+DATA/eq0/onlinelog/group_4A.dbf') SIZE 200M reuse;

ALTER DATABASE ADD LOGFILE shu 4 ('+ARCH', '+DATA') SIZE 200M reuse;

alter database add STANDBY LOGFILE GROUP 5 ('+DATA', '+ARCH') SIZE 200M BLOCKSIZE 512 reuse;
alter database add STANDBY LOGFILE GROUP 6 ('+DATA', '+ARCH') SIZE 200M BLOCKSIZE 512 reuse;
alter database add STANDBY LOGFILE GROUP 6 ('+DATA/eq0/standbylog/standby_redo6A.dbf', '+ARCH/eq0/standbylog/standby_redo6B.dbf') SIZE 200M BLOCKSIZE 512 reuse;

show parameters STANDBY
ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO scope=both sid='*';

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE NODELAY DISCONNECT FROM SESSION;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT;

ALTER SYSTEM SET db_recovery_file_dest='';

@eq0A:

SET LINESIZE  145
SET PAGESIZE  9999
col "type" for a7
col member for a42
select * from v$logfile order by 1,4;
SELECT GROUP#, ARCHIVED, STATUS FROM V$LOG;

ALTER DATABASE DROP LOGFILE GROUP 1;
ALTER DATABASE DROP LOGFILE GROUP 2;
ALTER DATABASE DROP LOGFILE GROUP 3;
ALTER DATABASE DROP LOGFILE GROUP 4;
ALTER DATABASE DROP LOGFILE GROUP 5;
ALTER DATABASE DROP LOGFILE GROUP 6;

ALTER DATABASE ADD LOGFILE GROUP 11 ('+ARCH/eq0/onlinelog/online11.dbf') size 200M REUSE;
ALTER DATABASE ADD LOGFILE GROUP 12 ('+ARCH/eq0/onlinelog/online12.dbf') size 200M REUSE;
ALTER DATABASE DROP LOGFILE GROUP 11;
ALTER DATABASE DROP LOGFILE GROUP 12;


ALTER DATABASE DROP LOGFILE MEMBER '+RECO';

ALTER DATABASE CLEAR LOGFILE GROUP 1;
ALTER DATABASE CLEAR LOGFILE GROUP 2;
ALTER DATABASE CLEAR LOGFILE GROUP 3;
ALTER DATABASE CLEAR LOGFILE GROUP 4;
ALTER DATABASE CLEAR LOGFILE GROUP 5;



run {
   set until scn  31494273;
   recover
   standby
   clone database
    delete archivelog;
}
run {
   recover
   standby
   clone database
    delete archivelog;
}


archive log list;
ALTER SESSION SET nls_date_format='DD-MON-YYYY HH24:MI:SS';
SELECT SEQUENCE#, FIRST_TIME, NEXT_TIME, STANDBY_DEST, ARCHIVED, APPLIED, DELETED, STATUS FROM V$ARCHIVED_LOG ORDER BY SEQUENCE#;

ALTER SYSTEM SWITCH LOGFILE;

alter system checkpoint;

alter system archive log current;

set linesize 999
col dest_name for a30
col DESTINATION for a40
SELECT dest_name, status, destination FROM v$archive_dest
where status != 'INACTIVE';

ALTER SYSTEM SET LOG_ARCHIVE_DEST_STATE_2=enable;

!cat /oracle/eq0/saptrace/diag/rdbms/eq0b/eq0/trace/alert*

-- to see database is standby or primary role
col DB_UNIQUE_NAME for a15
SELECT DB_UNIQUE_NAME, OPEN_MODE, DATABASE_ROLE FROM v$database;

-- if is "PRIMARY"
ALTER DATABASE CONVERT TO PHYSICAL STANDBY;

shutdown immediate;
STARTUP MOUNT;

SELECT database_role FROM v$database;

-- after that, it should be: PHYSICAL STANDBY

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

col name for a45
select file#, status, enabled, name from v$datafile;

alter database flashback OFF;

-- Shutdown database
SHUTDOWN IMMEDIATE;
-- Start database again with Mount option
STARTUP MOUNT
-- Change database to Noarchivelog mode 
ALTER DATABASE NOARCHIVELOG;
--ALTER DATABASE ARCHIVELOG;
-- Open database
ALTER DATABASE OPEN ;

alter database flashback ON;

rman TARGET sys/drSAP01ED0@ED0a auxiliary sys/drSAP01EQ0@ED0
rman TARGET sys/drSAP01EQ0@eq0a auxiliary sys/drSAP01EQ0@eq0
rman TARGET sys/drSAP01EQ0@eq0a auxiliary sys/drSAP01EQ0@eq0

sql "alter system disable restricted session";

rman TARGET  /
sql "alter system enable restricted session";
drop database including backups;


