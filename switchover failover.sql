-- https://oracle-base.com/articles/11g/data-guard-setup-11gr2#switchover

-- ### GOTO PRIMARY
PROMPT Switchover to Primary
ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;

PROMPT Shutdown standby database
SHUTDOWN IMMEDIATE;

PROMPT Open old standby database as primary
STARTUP;
ALTER SYSTEM SWITCH LOGFILE;

--!lsnrctl start

@status

--### GOTO STANDBY
prompt switchover to standby
ALTER DATABASE COMMIT TO SWITCHOVER TO STANDBY;

prompt shutdown immediate...
SHUTDOWN IMMEDIATE;

prompt Starting standby read only
STARTUP MOUNT;
ALTER DATABASE OPEN READ ONLY;

--STARTUP NOMOUNT;
--ALTER DATABASE MOUNT STANDBY DATABASE;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

@status

Failover

If the primary database is not available the standby database can be activated as a primary database using the following statements.

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE FINISH;
ALTER DATABASE ACTIVATE STANDBY DATABASE;
Since the standby database is now the primary database it should be backed up immediately.

The original primary database can now be configured as a standby. If Flashback Database was enabled on the primary database, 
then this can be done relatively easily (shown here). If not, the whole setup process must be followed, but this time using the original primary server as the standby.


## http://www.oracle.com/technetwork/pt/articles/database-performance/duplicate-active-dataguard-11-3437184-ptb.html

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL; -- Cancela o recover da base.
ALTER DATABASE ACTIVATE STANDBY DATABASE; -- Ativa a base de standby como produção.
ALTER DATABASE OPEN; -- Abre a base em modo read/write

