rman target / nocatalog
CONFIGURE DEVICE TYPE DISK PARALLELISM 1 BACKUP TYPE TO BACKUPSET;
CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY BACKED UP 3 TIMES TO DISK;
CONFIGURE RETENTION POLICY TO REDUNDANCY 3;
configure controlfile autobackup on;
-- crontab -e
#-- Item Description 
#-- minute	0 through 59
#-- hour	0 through 23
#-- day_of_month	1 through 31
#-- month	1 through 12
#-- weekday	0 through 6 for Sunday through Saturday: 0 domingo, 1 segunda,2 terca, 3 quarta, 4 quinta, 5 sexta, 6 sabado
#-- command	a shell command

--dev1:
# FULL 8h de sabado
0 8 * * 6 /backup/bk.sh full >> /backup/backup.crontab.log
# INCREMENTAL 8h de quarta-feira
0 8 * * 3 /backup/bk.sh incr >> /backup/backup.crontab.log
# ARCHIVELOG a cada 1h das 5 as 20h
0 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20 * * 1,2,3,4,5 /backup/bk.sh arch >> /backup/backup.crontab.log
--qa1:
# FULL 12h de domingo
0 12 * * 0 /backup/bk.sh full >> /backup/backup.crontab.log
# INCREMENTAL 6h de quarta-feira
0 8 * * 3 /backup/bk.sh incr >> /backup/backup.crontab.log
# ARCHIVELOG a cada 1h das 5 as 20h
20 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20 * * 1,2,3,4,5 /backup/bk.sh arch >> /backup/backup.crontab.log
--prod2:
# FULL 21h todos os dias
0 21 * * 6 /backup/bk.sh full >> /backup/backup.crontab.log
# INCREMENTAL 8h de quarta-feira
0 8 * * 3 /backup/bk.sh incr >> /backup/backup.crontab.log
# ARCHIVELOG a cada 1h das 2 as 20h
40 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20 * * 1,2,3,4,5 /backup/bk.sh arch >> /backup/backup.crontab.log


catalog start with '/backup/arch';
catalog start with '/backup/data';
catalog start with '/backup/cf';

run {
 ALLOCATE CHANNEL chan1 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan2 DEVICE TYPE DISK;
 crosscheck backupset;
 crosscheck archivelog all;
}
report device type disk schema;
report obsolete
 until time "to_date('2017-09-06:00:00:00', 'yyyy-mm-dd:hh24:mi:ss')";
delete obsolete
 
list archivelog all;
delete archivelog all until time 'sysdate-5';

list backup summary;
list archivelog all;


delete backupset completed after "to_date('2017-09-26:00:00:00', 'yyyy-mm-dd:hh24:mi:ss')";


delete backupset until time "to_date('2017-09-26:12:00:00', 'yyyy-mm-dd:hh24:mi:ss')";
tag TAG20170927T084003

crosscheck backupset;
crosscheck archivelog all;
list expired backupset summary;
list expired archivelog all;
delete expired archivelog all;
delete noprompt expired archivelog all;


#  %e: archlog number
#  %d: dbname
#  %s: backupset number
#  %p: backup piece number
#  %c: copy number
#  %u: name compressed representation
#  %t: bkup timestamp

---- cat > bk.sh <<EOF
#!/bin/csh

date

setenv ORACLE_HOME /oracle/ED0/11204
setenv ORACLE_SID ED0
setenv ORACLE_BIN /oracle/ED0/11204/bin

cd /backup

$ORACLE_BIN/rman target / cmdfile=backup_$1.rman append log=backup.log 

date

EOF

---- cat > backup.rman <<EOF
#rman target / append log=backup.log cmdfile=backup.rman 
host 'date >> backup.log';
#connect target /
#sql 'alter system archive log current';
sql "alter session set nls_date_format=''dd.mm.yyyy hh24:mi:ss''";

RUN 
{
 ALLOCATE CHANNEL chan1 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan2 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan3 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan4 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan5 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan6 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan7 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan8 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan9 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan10 DEVICE TYPE DISK;
 configure controlfile autobackup on;
 set command id to 'ORCLOnlineBackupFull';

 backup AS COMPRESSED BACKUPSET incremental level 1 cumulative
   format '/backup/data/%d_incr_u%u_s%s_p%p_t%t';
 #backup AS COMPRESSED BACKUPSET full database
 #  format '/backup/data/%d_full_u%u_s%s_p%p_t%t';
 CROSSCHECK BACKUPSET;
 --delete expired backupset until 'sysdate-12';
}

run {
 ALLOCATE CHANNEL cfspf DEVICE TYPE DISK;
 backup as compressed backupset
   current controlfile spfile
   format '/backup/cf/%d_controlspfile_u%u_s%s_p%p_t%t';

 CROSSCHECK BACKUPSET;
 CROSSCHECK ARCHIVELOG ALL;
 CROSSCHECK DATAFILECOPY ALL;

 delete obsolete until time 'sysdate-14';
 
}

host 'date >> backup.log';
host 'du -g /backup/data/* >> backup.log';
@backup_archlog.rman
exit
EOF

----

---- cat > backup_archlog.rman <<EOF
#rman target / append log=backup.log cmdfile=backup_ArchLog.rman 

host 'date >> backup.log';
#connect target /
#sql 'alter system archive log current';
sql "alter session set nls_date_format=''dd.mm.yyyy hh24:mi:ss''";
RUN
{
 ALLOCATE CHANNEL chan1 DEVICE TYPE DISK;
 set command id to 'ORCLOnlineBackupArchLog';
  backup as compressed backupset 
   archivelog all not backed up 
   delete all input
   format '/backup/arch/arc_%d_e%e_s%s_p%p_c%c_u%u_t%t';

 crosscheck archivelog all;
 delete expired archivelog all;
}

host 'date >> backup.log';
host 'du -g /backup/arch/* >> backup.log';
exit
EOF
backup as compressed backupset archivelog all not backed up 
  format '/backup/arch/arc_%d_e%e_s%s_p%p_c%c_u%u_t%t';

----
run {
 ALLOCATE CHANNEL chan1 DEVICE TYPE DISK;
 crosscheck archivelog all;
}

----- restore, recover
run{
 shutdown immediate;
 startup mount;
 ALLOCATE CHANNEL chan1 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan2 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan3 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan4 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan5 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan6 DEVICE TYPE DISK;
 set until time "to_date('2017-09-26:12:00:00', 'yyyy-mm-dd:hh24:mi:ss')";
 restore database;
 switch datafile all;
 recover database;
}

list backupset completed before 'sysdate-1';
alter database backup controlfile to trace as 'controlfile.ctl';

run{
 ALLOCATE CHANNEL chan1 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan2 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan3 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan4 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan5 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan6 DEVICE TYPE DISK;
 set until time "to_date('2017-09-26:12:00:00', 'yyyy-mm-dd:hh24:mi:ss')";
 restore database using backup controlfile;
}

set until time "to_date('2017-09-26:12:00:00', 'yyyy-mm-dd:hh24:mi:ss')";

set until restore point "to_date('2017-09-26:12:00:00', 'yyyy-mm-dd:hh24:mi:ss')";

restore controlfile from autobackup until time "to_date('2017-09-26:12:00:00', 'yyyy-mm-dd:hh24:mi:ss')";

run{
 set until time "to_date('2017-09-26:12:00:00', 'yyyy-mm-dd:hh24:mi:ss')";
 restore controlfile;
}

 
run{
 ALLOCATE CHANNEL chan1 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan2 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan3 DEVICE TYPE DISK;
 ALLOCATE CHANNEL chan4 DEVICE TYPE DISK;
 set until time "to_date('2017-09-26:12:00:00', 'yyyy-mm-dd:hh24:mi:ss')";
 restore datafile;
 recover database;
}

run{
 shutdown immediate;
 startup mount;
 set until time "to_date('2017-09-26:12:00:00', 'yyyy-mm-dd:hh24:mi:ss')";
 restore database;
 recover database;
 alter database open resetlogs;
}

run {
 ALLOCATE CHANNEL chan1 DEVICE TYPE DISK;
 crosscheck archivelog all;
}


-- check estimated backup size

select ctime "Date"
 , decode(backup_type, 'L', 'Archive Log', 'D', 'Full', 'Incremental') backup_type
 , bsize "Size MB"
from (select bp.completion_time as ctime
		, backup_type
		, round(sum(bp.bytes/1024/1024),2) bsize
	   from v$backup_set bs, v$backup_piece bp
	   where bs.set_stamp = bp.set_stamp
	   and bs.set_count  = bp.set_count
	  and bp.status = 'A'
	  group by bp.completion_time, backup_type)
order by 1, 2;


COL in_size  FORMAT a10
COL out_size FORMAT a10
SELECT SESSION_KEY, 
       INPUT_TYPE,
       COMPRESSION_RATIO,       
       OUTPUT_BYTES_DISPLAY out_size
FROM   V$RMAN_BACKUP_JOB_DETAILS
ORDER BY SESSION_KEY;

-- blocks writeen to a cabkup set
select file#, incremental_level, completion_time, blocks, datafile_blocks
  from v$backup_datafile
  --where incremental_level > 0 and blocks / datafile_blocks > .5
  order by completion_time, file#;


--- erro com control file
-- ORA-19606: Cannot copy or restore to snapshot control file
show snapshot controlfile name
crosscheck controlfilecopy '/oracle/EQ0/11204/dbs/snapcf_EQ0.f';
delete expired controlfilecopy '/oracle/EQ0/11204/dbs/snapcf_EQ0.f';
delete obsolete;
configure snapshot controlfile name to clear;