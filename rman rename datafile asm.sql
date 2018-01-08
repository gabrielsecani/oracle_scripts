-- begin dfn.csh
#!/bin/csh
## How to use
# ./dfn.csh initial_datafile end_datafile
# ./dfn.csh 6 63

@ i = $1
while ($i <= $2)
  echo $i
  rman target / cmdfile dfn.rman $i
  @ i += 1
end

-- end dfn.csh

-- begin dfn.rman
SQL "ALTER DATABASE DATAFILE &1 OFFLINE";
backup as copy datafile &1 format '+DATA';
switch datafile &1 to copy;
recover DATAFILE &1;
SQL "ALTER DATABASE DATAFILE &1 ONLINE";
delete noprompt copy of datafile &1;
-- end dfn.rman


-- using datafile rename from database / rman copy

col FILE_NAME for a50
col TABLESPACE_NAME for a15
select file_id, file_name, tablespace_name from dba_data_files;
SQL> alter tablespace test2 offline;
RMAN> copy datafile '+DATA/v11203/datafile/test1.268.789380535' to '+DATA';
SQL> alter database rename file '+DATA/v11203/datafile/test1.268.789380535' to '+DATA/v11203/datafile/test2.269.789380645';
SQL> alter tablespace test2 online;

--- using rman copy switch datafile
rman target /

REPORT SCHEMA;
--- FILE_ID FILE_NAME                          TABLESPACE_NAME
--- 7 +DATA/v11203/datafile/test1.269.789411511          TEST2
 
sql "alter tablespace test2 offline";
--ou
SQL "ALTER DATABASE DATAFILE 64 OFFLINE";

backup as copy datafile 64 format '+DATA';
ou
BACKUP AS COPY
        DATAFILE "+DATA/orcl/datafile/users.261.689589837"
        FORMAT   "+DATA";

SWITCH DATAFILE "+DATA/ep0/datafile/psapsr3701.326.952168171" TO COPY;
--ou
switch datafile 64 to copy;
recover DATAFILE 64;

sql "alter tablespace test2 online";
--ou
SQL "ALTER DATABASE DATAFILE 64 ONLINE";

delete noprompt copy of datafile 64;

rman target / cmdfile dfn.rman 5


./dfn.csh 10 15 >> log6_15.log &
./dfn.csh 20 25 >> log16_25.log &
./dfn.csh 29 31 >> log26_35.log &
./dfn.csh 41 45 >> log36_45.log &
./dfn.csh 49 55 >> log46_55.log &
./dfn.csh 59 63 >> log56_63.log &

./dfn.csh 32 32 >> log32_35.log &
./dfn.csh 33 33 >> log32_35.log &
./dfn.csh 34 34 >> log32_35.log &
./dfn.csh 35 35 >> log32_35.log &

tail -f  log6_15.log &
tail -f log16_25.log &
tail -f log26_35.log &
tail -f log36_45.log &
tail -f log46_55.log &
tail -f log56_63.log &


CONFIGURE DEVICE TYPE DISK PARALLELISM 1 BACKUP TYPE TO BACKUPSET;
SQL "ALTER SYSTEM CHECKPOINT";
report schema;
list datafilecopy all;


backup as copy datafile 1 format '+DATA';
SQL "ALTER DATABASE DATAFILE 1 OFFLINE";
switch datafile 1 to copy;
recover DATAFILE 1;
SQL "ALTER DATABASE DATAFILE 1 ONLINE";
delete noprompt copy of datafile 1;

backup as copy datafile 2 format '+DATA';
SQL "ALTER DATABASE DATAFILE 2 OFFLINE";
switch datafile 2 to copy;
recover DATAFILE 2;
SQL "ALTER DATABASE DATAFILE 2 ONLINE";
delete noprompt copy of datafile 2;

backup as copy datafile 3 format '+DATA';
SQL "ALTER DATABASE DATAFILE 3 OFFLINE";
switch datafile 3 to copy;
recover DATAFILE 3;
SQL "ALTER DATABASE DATAFILE 3 ONLINE";
delete noprompt copy of datafile 3;

backup as copy datafile 4 format '+DATA';
SQL "ALTER DATABASE DATAFILE 4 OFFLINE";
switch datafile 4 to copy;
recover DATAFILE 4;
SQL "ALTER DATABASE DATAFILE 4 ONLINE";
delete noprompt copy of datafile 4;


dfn = 1;
export dfn;

SQL "ALTER DATABASE DATAFILE $dfn OFFLINE";
backup as copy datafile $dfn format '+DATA';
switch datafile $dfn to copy;
recover DATAFILE $dfn;
SQL "ALTER DATABASE DATAFILE $dfn ONLINE";
delete noprompt copy of datafile $dfn;
