--### GOTO PRIMARY
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;

PROMPT Switchover to Primary
ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
--alter database convert to physical standby;
--ALTER DATABASE ACTIVATE PHYSICAL STANDBY DATABASE;

alter database open resetlogs;

PROMPT Shutdown standby database
SHUTDOWN IMMEDIATE;

PROMPT Open old standby database as primary
STARTUP;

@status

