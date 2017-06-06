-- desabilita broker 
sql 'ALTER SYSTEM SET DG_BROKER_START=false';
sql 'ALTER SYSTEM SET DG_BROKER_START=true';

alter system set LOG_ARCHIVE_DEST_2='SERVICE=EQ0B ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=EQ0B';
alter system set log_archive_dest_2='SERVICE=EQ0A ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=EQ0A';

sqlplus sapsr3/DRSAP01EQ0@eq0

sqlplus sys/drSAP01EQ0@eq0 as sysdba
sqlplus sys/drSAP01EQ0@eq0a as sysdba
sqlplus sys/drSAP01EQ0@eq0b as sysdba

rman TARGET sys/drSAP01EQ0@eq0b

alter system set local_listener='(ADDRESS=(PROTOCOL=TCP)(HOST=sapqa1)(PORT = 1521))';
alter system set local_listener='(ADDRESS=(PROTOCOL=TCP)(HOST=sapqa2)(PORT = 1521))';
alter system set local_listener=sapqa2;


dgmgrl SYS/drSAP01EQ0
connect SYS/drSAP01EQ0

disable CONFIGURATION 
enable CONFIGURATION 

REMOVE DATABASE EQ0B
REMOVE CONFIGURATION;

CREATE CONFIGURATION FSFOCONFIG AS
  PRIMARY DATABASE IS EQ0A
  CONNECT IDENTIFIER IS EQ0A;

ADD DATABASE EQ0B as 
  CONNECT IDENTIFIER IS EQ0B maintained as physical;

  REMOVE DATABASE EQ0B


SHOW CONFIGURATION; 
show database EQ0A InconsistentProperties
show database EQ0B InconsistentProperties


[14:43:07] Diana: Disable the broker configuration using the DGMGRL DISABLE command. 

Stop the Data Guard broker DMON process using the following SQL statement:

