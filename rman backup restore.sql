CONFIGURE DEVICE TYPE DISK PARALLELISM 8 BACKUP TYPE TO BACKUPSET;
CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY BACKED UP 1 TIMES TO DISK;

--backup
run{
 --shutdown immediate;
 --startup mount;
 allocate channel a1 type disk;-- format '+DATA/backup/bkp_%Y%M%D_%n';
 --allocate channel a2 type disk;-- format '+DATA/backup/bkp_%Y%M%D_%n';
 backup as compressed backupset database;
 backup current controlfile; -- format '+DATA/backup/ctrl_%Y%M%D%n';
 release channel a1;
 --release channel a2;
 --alter database open;
}

sql 'alter system archive log current';
sql "alter session set nls_date_format=''dd.mm.yyyy hh24:mi:ss''";
RUN
{
 configure controlfile autobackup on;
 set command id to 'ORCLOnlineBackupFull';
 allocate channel c1 type disk;
 allocate channel c2 type disk;
 allocate channel c3 type disk;
 allocate channel c4 type disk;
 allocate channel c5 type disk;
 allocate channel c6 type disk;
 allocate channel c7 type disk;
 backup AS COMPRESSED BACKUPSET full database;
 sql 'alter system archive log current';
 backup archivelog all delete all input;
 backup current controlfile;
 release channel c1;
 release channel c2;
 release channel c3;
 release channel c4;
 release channel c5;
 release channel c6;
 release channel c7;
}

--restore, recover
run{
 shutdown immediate;
 startup mount;
 restore database from tag 'TAG20170411T135927';
 switch datafile all;
 recover database;
 }

run {
 shutdown immediate;
 startup mount;
 set until time "to_date('2017-05-06:00:00:00', 'yyyy-mm-dd:hh24:mi:ss')";
 restore database;
 recover database;
 alter database open resetlogs;
}

run {
 set until time "to_date('2017-05-06:00:00:00', 'yyyy-mm-dd:hh24:mi:ss')";
 crosscheck archivelog all;
}


run {
crosscheck archivelog all;
backup as backupset archivelog all delete input;
}
