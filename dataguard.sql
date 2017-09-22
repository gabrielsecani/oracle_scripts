-- desabilita broker 
sql 'ALTER SYSTEM SET DG_BROKER_START=false';
sql 'ALTER SYSTEM SET DG_BROKER_START=true scope=both';
sql 'alter database set standby database to maximize availability';


alter system set LOG_ARCHIVE_DEST_2='SERVICE=EQ0 ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=EQ0';
alter system set log_archive_dest_2='SERVICE=EP0A ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=EP0A';

sqlplus sapsr3/DRSAP01EQ0@EQ0
sqlplus sapsr3/DRSAP01EQ0@EQ0

sqlplus sys/drSAP01EP0@EP0 as sysdba
sqlplus sys/drSAP01EP0@EP0a as sysdba
sqlplus sys/drSAP01EP0@EQ0 as sysdba

rman TARGET sys/drSAP01EP0@EQ0

alter system set local_listener='(ADDRESS=(PROTOCOL=TCP)(HOST=sapprod1)(PORT=1527))' scope=both;
alter system set local_listener='(ADDRESS=(PROTOCOL=TCP)(HOST=sapprod2)(PORT=1527))' scope=both;
alter system set local_listener='' scope=both;

sqlplus system/DRSAP01EQ0@EQ0b

sqlplus system/DRSAP01ED0@ed

dgmgrl SYS/drSAP01EP0
connect SYS/drSAP01EP0

disable CONFIGURATION 
enable CONFIGURATION 

REMOVE DATABASE EQ0A
REMOVE CONFIGURATION;

CREATE CONFIGURATION FSFOCONFIG AS PRIMARY DATABASE IS EQ0A CONNECT IDENTIFIER IS EQ0A;
ADD DATABASE EQ0B as  CONNECT IDENTIFIER IS EQ0B maintained as physical;

CREATE CONFIGURATION FSFOCONFIG AS PRIMARY DATABASE IS EQ0B CONNECT IDENTIFIER IS EQ0B;
ADD DATABASE EQ0A as  CONNECT IDENTIFIER IS EQ0A maintained as physical;


SHOW CONFIGURATION verbose

show database EQ0A InconsistentProperties
show database EQ0B InconsistentProperties
show database EQ0 InconsistentProperties

lsnrctl stop
lsnrctl start
lsnrctl service

exit


SHOW DATABASE EQ0 'InconsistentProperties';

SHOW DATABASE VERBOSE EP0A;
SHOW DATABASE VERBOSE EQ0;

EDIT DATABASE EP0A SET PROPERTY 'RedoCompression'='ENABLE';
EDIT DATABASE EP0A SET PROPERTY 'StandbyFileManagement'='AUTO';


EDIT CONFIGURATION SET PROTECTION MODE AS MAXPERFORMANCE;
EDIT CONFIGURATION SET PROTECTION MODE AS MAXAVAILABILITY;
