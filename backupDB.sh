#!/bin/sh
# Purpose:       Performs RMAN backup of database to disk using parallelism.
# Version:       3.20
# Prerequisites:
#                1. Oracle version must be 10.2 or later.
#                2. Database must be in Archive Log mode.
#                3. Ensure you have ample disk space for the backup destination.
#                4. Ensure Sys Admin backs up your RMAN backup files routinely.
#------------------------------------------------------------------------------
# Usage:         Change user variables as required to match your environment.
#
# ARCHIVE_LOGS   If "Y" archive logs will be backed up and managed by RMAN.
# BACKUP_FILE_DESTS Space delimited list of file paths.
#                   Example: BACKUP_FILE_DESTS="/oradata/rman1 /oradata/rman2"
#                
# EMAIL_ADDRESS  Email address to send any errors to.
# LEVEL0_DAY     Day Level 0 (FULL) Backup Runs. Values: Mon Tue Wed Thu Fri Sat Sun
# VALIDATE       If "Y" level 0 backups will be validated. 
#
# CFRKT          CONTROL_FILE_RECORD_KEEP_TIME
#                How long to retain RMAN restoration information. Ex: CFRKT=30
# OBSOLETE       When files on disk are considered OBSOLETE and can be deleted.
#                The value for OBSOLETE must be less than or equal to CFRKT.  Ex: OBSOLETE=14
#------------------------------------------------------------------------------
# Command Line: You can override the backup level by passing the corresponding
#               command line value (0 or 1). Example: ./backupDB.sh 0
################################################################################

########################################
# Init User Variables
########################################

# Init Oracle Env
ORACLE_SID="DB1"
ORACLE_BASE="/home/oracle"
ORACLE_HOME="$ORACLE_BASE/product/10.2/db" 
LD_LIBRARY_PATH="$ORACLE_HOME/lib"
export ORACLE_SID ORACLE_BASE ORACLE_HOME LD_LIBRARY_PATH

# RMAN Vars
ARCHIVE_LOGS="Y"
BACKUP_FILE_DESTS="/export/oradata/recovery/rman1/$ORACLE_SID /export/oradata/recovery/rman2/$ORACLE_SID"
EMAIL_ADDRESS="scott.tiger@myurl.com"
LEVEL0_DAY="Fri"
VALIDATE="Y"

# Retention Policy
CFRKT="45"   
OBSOLETE="8" 

################################################################################
################################################################################
###########         DO NOT CHANGE ANYTHING BELOW THIS LINE          ############
################################################################################
################################################################################

########################################
# Header
######################################## 
clear
echo "===> $0 started"
echo "     ORACLE_SID:         $ORACLE_SID"
echo "     ORACLE_BASE:        $ORACLE_BASE"
echo "     ORACLE_HOME:        $ORACLE_HOME"
echo "     LD_LIBRARY_PATH:    $LD_LIBRARY_PATH"
echo "     ---------------------------------------------------"
echo "     ARCHIVE_LOGS:       $ARCHIVE_LOGS"
echo "     BACKUP_FILE_DESTS:  $BACKUP_FILE_DESTS"
echo "     EMAIL_ADDRESS:      $EMAIL_ADDRESS"
echo "     VALIDATE:           $VALIDATE"
echo "     LEVEL0_DAY:         $LEVEL0_DAY"
sleep 7


########################################
# Set Backup Level (check for cmd line)
########################################
BACKUP_LEVEL="0"
DAY=`date | cut -d ' ' -f1`
if [ $# -ne 0 ]; then
   if [ "$1" = "0" ]; then
      BACKUP_LEVEL="0"
   else
      BACKUP_LEVEL="1"         
   fi
else
   if [ "$DAY" = "$LEVEL0_DAY" ]; then 
      BACKUP_LEVEL="0"
   else
      BACKUP_LEVEL="1"
   fi
fi
echo "\n\n===> Backup Level: $BACKUP_LEVEL ($DAY)"


########################################
# Init System Variables
######################################## 
PATH=/bin:$PATH
SCRIPTNAME=`basename $0 .sh`
DATE_STAMP=`date '+%Y%m%d'`
TIME_STAMP=`date '+%H%M'`
DATE_START=`date`
MONTH=`date '+%m'`
#
NOW=$DATE_STAMP.$TIME_STAMP
FORMAT=%d_%T_%s_%p.bus
TAG="$NOW Level $BACKUP_LEVEL"
unalias cp
unalias rm


########################################
# Set CONTROL_FILE_RECORD_KEEP_TIME
########################################
echo "\n\n===> Setting CONTROL_FILE_RECORD_KEEPTIME: $CFRKT"
$ORACLE_HOME/bin/sqlplus "/ as sysdba" << SQLPLUS_SESSION
ALTER SYSTEM SET CONTROL_FILE_RECORD_KEEP_TIME=$CFRKT SCOPE=BOTH;
exit
SQLPLUS_SESSION
sleep 3


########################################
# Build Channel Entries
########################################
echo "\n\n===> Building channel entries..."
i=1
DEST1="-999"
CHANNELS="-999"

for DEST in $BACKUP_FILE_DESTS
do
   # Get First Backup Dest
   if [ "$DEST1" = "-999" ]; then
      DEST1="$DEST"
   fi

   # Build CHANNEL String
   if [ "$CHANNELS" = "-999" ]; then
      CHANNELS="configure channel $i device type disk format '$DEST/$FORMAT' maxpiecesize 50g;"
   else
      CHANNELS="$CHANNELS configure channel $i device type disk format '$DEST/$FORMAT' maxpiecesize 50g;"
   fi
   i=`expr $i + 1`
done
PARALLELISM=`expr $i - 1`


########################################
# Set Log File Dirs
########################################
echo "\n\n===> Setting log file dirs..."
LOG_BACKUP=$DEST1/$SCRIPTNAME.$NOW.backup_lvl$BACKUP_LEVEL.log
LOG_CFG=$DEST1/$SCRIPTNAME.$NOW.cfg.log
LOG_MAINT=$DEST1/$SCRIPTNAME.$NOW.maint.log
LOG_VALIDATE=$DEST1/$SCRIPTNAME.$NOW.validate.log
LOG_FILES=$DEST1/$SCRIPTNAME.$NOW.files.log


########################################
# Set RMAN Configuration Parameters
########################################
echo "\n\n===> Setting RMAN parameters...\n"
$ORACLE_HOME/bin/rman target / nocatalog log=$LOG_CFG << RMAN_SESSION
   configure device type disk backup type to compressed backupset parallelism $PARALLELISM;
   configure archivelog backup copies for device type disk to 1;
   configure backup optimization off;
   $CHANNELS
   configure controlfile autobackup on;
   configure controlfile autobackup format for device type disk to '$DEST1/%F';
   configure datafile backup copies for device type disk to 1;
   configure default device type to disk;
   configure maxsetsize to unlimited;
   configure retention policy to recovery window of $OBSOLETE days;
   configure snapshot controlfile name to '$DEST1/snapshot.ctl';
   show all;
RMAN_SESSION


########################################
# Enable\Disable Archive Log Commands
########################################
if [ "$ARCHIVE_LOGS" = "Y" -o "$ARCHIVE_LOGS" = "y" ]; then
   echo "\n\n===> Manage Archive Logs: ENABLED"
   ARCHIVE_LOGS_CMD1="plus archivelog"
   ARCHIVE_LOGS_CMD2="delete all input"
else
   echo "\n\n===> Manage Archive Logs: DISABLED" 
   ARCHIVE_LOGS_CMD1="#plus archivelog"
   ARCHIVE_LOGS_CMD2="#delete all input"
fi


########################################
# RMAN Maintenance
# 1. Crosscheck files.
# 2. Delete obsolete backupsets.
########################################
echo "\n\n===> Crosschecking files then deleting obsolete backupsets...\n"
$ORACLE_HOME/bin/rman target / nocatalog log=$LOG_MAINT << RMAN_SESSION
   allocate channel for maintenance type disk;
   crosscheck backup;
   crosscheck archivelog all;
   delete force noprompt obsolete;
RMAN_SESSION


########################################
#
# RMAN Backup Session
#
########################################
echo "\n\n\n===> Performing RMAN Backup...\n"
$ORACLE_HOME/bin/rman target / nocatalog log=$LOG_BACKUP << RMAN_SESSION 
run {
   # Backup Command Execution
   backup
      incremental level $BACKUP_LEVEL
      database
      $ARCHIVE_LOGS_CMD1
      $ARCHIVE_LOGS_CMD2
      tag '$TAG'
   ;
   sql 'alter system archive log current';

   # Redundancy Redundancy Redundancy is good.
   sql 'alter database backup controlfile to trace';
   sql "CREATE PFILE=''$DEST1/init$ORACLE_SID.ora'' FROM spfile";
}
exit
RMAN_SESSION

# Error Check Backup
ERROR_BACKUP=N
grep -i ERROR $LOG_BACKUP && ERROR_BACKUP="Y"
if [ "$ERROR_BACKUP" = "Y" ]; then
   echo "\n\n   ERROR_BACKUP: $ERROR_BACKUP"
   MESSAGE="RMAN Backup problem with $ORACLE_SID"
   echo "$MESSAGE" | mailx -s "DBA Alert: RMAN Error" $EMAIL_ADDRESS
fi


########################################
# Validate RMAN Backup
########################################
if [ "$ERROR_BACKUP" != "Y" ]; then
   if [ "$VALIDATE" = "Y" -o "$VALIDATE" = "y" -a "$DAY" = "$LEVEL0_DAY" ]; then
      echo "\n\n\n===> Validating Backup...\n"
      $ORACLE_HOME/bin/rman target / nocatalog log=$LOG_VALIDATE << RMAN_SESSION
      allocate channel for maintenance type disk;
      restore database validate;
RMAN_SESSION
   fi
fi


########################################
# Backup Files RMAN Does Not
########################################
if [ "$DAY" = "$LEVEL0_DAY" ]; then
   echo "\n\n===> Backing up config and log files...\n"
   CFILES=$DEST1/zConfig_Files/$MONTH
   mkdir $DEST1/zConfig_Files  > /dev/null 2>&1 
   mkdir $CFILES               > /dev/null 2>&1 
   mkdir $CFILES/cron          > /dev/null 2>&1 
   if [ -d $CFILES ]; then
      cat /etc/system >                             $CFILES/system
      cp $HOME/.cshrc                               $CFILES/.       >  /dev/null
      cp /var/opt/oracle/oratab                     $CFILES/.       >  /dev/null
      cp /var/opt/oracle/oraInst.loc                $CFILES/.       >  /dev/null
      cp $ORACLE_BASE/admin/$ORACLE_SID/bdump/alert_$ORACLE_SID.log $CFILES/.  >  /dev/null
      cp $ORACLE_HOME/network/admin/listener.ora    $CFILES/.       >  /dev/null
      cp $ORACLE_HOME/network/log/listener.log      $CFILES/.       >  /dev/null
      cp $ORACLE_HOME/network/admin/tnsnames.ora    $CFILES/.       >  /dev/null
      cp $ORACLE_HOME/network/admin/sqlnet.ora      $CFILES/.       >  /dev/null
      cp $ORACLE_BASE/cron/*.*                      $CFILES/cron    >  /dev/null
   else
      echo "$CFILES does not exist."                                >  /dev/null
   fi
fi


########################################
# Housekeeping
########################################
echo "\n===> Housekeeping ..."
# Purge Other Obsolete Files
find $DEST1 -name "c-*"  -type f -mtime +$OBSOLETE -exec rm {} \;
find $DEST1 -name ".ctl" -type f -mtime +$OBSOLETE -exec rm {} \;
find $DEST1 -name ".log" -type f -mtime +$OBSOLETE -exec rm {} \;


########################################
# End
######################################## 
DATE_END=`date`
echo "\n\n===> $SCRIPTNAME.sh Ended"
echo "     Backup Dest 1:      $DEST1"
echo "     Log File:           $LOG_BACKUP"
echo "     Start Time:         $DATE_START"
echo "     End Time:           $DATE_END\n\n"
