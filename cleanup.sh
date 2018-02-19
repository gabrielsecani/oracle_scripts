export ORACLE_SID=standby1
sqlplus / as sysdba << EOI
shutdown immediate
exit
EOI

export ORACLE_SID=orcl
sqlplus / as sysdba << EOI
alter system set dg_broker_start=false;
alter system reset log_archive_config;
alter system reset log_archive_dest_2;
shutdown immediate
startup mount
alter database noarchivelog;
shutdown immediate
startup
alter database drop standby logfile group 4;
alter database drop standby logfile group 5;
alter database drop standby logfile group 6;
alter database drop standby logfile group 7;
exit
EOI

rm -rf /u01/app/oracle/admin/standby1
rm -rf /u01/app/oracle/oradata/standby1
rm -f /u01/app/oracle/oradata/orcl/srl0*.log
rm -rf /u01/app/oracle/flash_recovery_area/STANDBY1
rm -rf $ORACLE_HOME/dbs/*standby1* 
rm -rf $ORACLE_HOME/dbs/dr*.dat
rm -rf $ORACLE_HOME/dbs/hc*.dat
rm -rf $ORACLE_HOME/dbs/lkSTANDBY1


