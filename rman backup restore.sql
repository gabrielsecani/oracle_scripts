rman target / nocatalog
CONFIGURE DEVICE TYPE DISK PARALLELISM 16 BACKUP TYPE TO BACKUPSET;
CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY BACKED UP 2 TIMES TO DISK;
configure controlfile autobackup on;

sql 'alter system archive log current';
run {
crosscheck archivelog all;
backup as backupset archivelog all delete input
format '/backup/arc_%d_full_bk_u%u_s%s_p%p_t%t' ;
}

list archivelog all;
delete archivelog all;
until time "to_date('2017-06-11:00:00:00', 'yyyy-mm-dd:hh24:mi:ss')";
list archivelog all
sql 'alter system archive log current';
run{
 configure controlfile autobackup on;

 crosscheck archivelog all;
 
 backup as compressed backupset 
 format '/backup/%d_full_bk_u%u_s%s_p%p_t%t' 
 INCREMENTAL LEVEL 0 
 database plus archivelog; 
 backup current controlfile;
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
 allocate channel c8 type disk;
 allocate channel c9 type disk;
 allocate channel c10 type disk;
 crosscheck archivelog all;
 backup AS COMPRESSED BACKUPSET full database
   format '/backup/%d_full_bk_u%u_s%s_p%p_t%t';
 sql 'alter system archive log current';
 backup archivelog all delete all input 
   format '/backup/%d_arc_bk_u%u_s%s_p%p_t%t';
 backup current controlfile;
 release channel c1;
 release channel c2;
 release channel c3;
 release channel c4;
 release channel c5;
 release channel c6;
 release channel c7;
 release channel c8;
 release channel c9;
 release channel c10;
}

RUN
{
 configure controlfile autobackup on;
 set command id to 'ORCLOnlineBackupFull';
 crosscheck archivelog all;
 backup AS COMPRESSED BACKUPSET full database;
 sql 'alter system archive log current';
 backup archivelog all delete all input;
 backup current controlfile;
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
 set until time "to_date('2017-06-16:00:00:00', 'yyyy-mm-dd:hh24:mi:ss')";
 restore database;
 recover database;
 alter database open resetlogs;
}

run {
 set until time "to_date('2017-05-06:00:00:00', 'yyyy-mm-dd:hh24:mi:ss')";
 crosscheck archivelog all;
}

