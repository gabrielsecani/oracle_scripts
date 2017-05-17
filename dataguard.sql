-- desabilita broker 
sql 'ALTER SYSTEM SET DG_BROKER_START=false';
sql 'ALTER SYSTEM SET DG_BROKER_START=true';


dgmgrl SYS/drSAP01ED0
connect SYS/drSAP01ED0

disable CONFIGURATION 
enable CONFIGURATION 

REMOVE CONFIGURATION;

CREATE CONFIGURATION SAPDEVCONFIG AS
  PRIMARY DATABASE IS ED0A
  CONNECT IDENTIFIER IS ED0A;

ADD DATABASE ED0B as CONNECT IDENTIFIER IS ED0B maintained as physical;
REMOVE DATABASE ED0B


SHOW CONFIGURATION; 
show database ED0A InconsistentProperties
show database ED0B InconsistentProperties


[14:43:07] Diana: Disable the broker configuration using the DGMGRL DISABLE command. 

Stop the Data Guard broker DMON process using the following SQL statement:

SQL> ALTER SYSTEM SET DG_BROKER_START=FALSE;
Change the configuration filenames for the database:

SQL> ALTER SYSTEM SET DG_BROKER_CONFIG_FILE1=filespec1;
SQL> ALTER SYSTEM SET DG_BROKER_CONFIG_FILE2=filespec2;

[14:43:34] Diana: When you change properties in a disabled configuration, it does not affect the actual database properties underneath because the changes are not applied to the running database until you reenable the configuration. For example, you might want to change the overall configuration protection mode and the redo transport services properties on a disabled configuration so that all changes are applied to the configuration at the same time upon the next enable operation.
[14:46:42] Diana: Restart the Data Guard broker DMON process, as follows:

SQL> ALTER SYSTEM SET DG_BROKER_START=TRUE;
[14:46:51] Diana: antes disso
[14:46:52] Diana: he method of moving the files depends upon where they currently reside and where you want to move them to:

If the files reside on an operating file system, use operating system commands to move the files to their new location.

If the files reside on raw devices, manually transfer the files to their new location.

If the old or new location is an ASM disk group, use the DBMS_FILE_TRANSFER.COPY_FILE function to transfer the files to their new location.
[14:47:24] Diana: esses arquivos existem  ?
[14:48:05] Diana: A configuration status reveals the overall health of the configuration. Status of the configuration is acquired from the status of all of its databases.

The following list describes the possible status modes for a configuration:

Success

The configuration, including all of the databases configured in it, is operating as specified by the user without any warnings or errors.

Warning

One or more of the databases in the configuration are not operating as specified by the user. To obtain more information, use the DGMGRL SHOW DATABASE <db-unique-name> StatusReport command or the Enterprise Manager display to locate each database and examine its status to reveal the source of the problem.

Error

One or more of the databases in the configuration failed or may no longer be operating as specified by the user. To obtain more information, use the DGMGRL SHOW DATABASE <db-unique-name> StatusReport command or the Enterprise Manager display to locate each database and examine its status to reveal the source of the problem.

Unknown/Disabled

Broker management of the configuration is disabled and the broker is not monitoring the status of the databases in the configuration.


