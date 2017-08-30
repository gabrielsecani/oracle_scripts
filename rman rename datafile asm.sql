-- begin dfn.csh
#!/bin/csh
@ i = 6
## How to use
# ./dfn.csh initial_datafile end_datafile
# ./dfn.csh 6 63

while ($i <= 63)
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




SQL "ALTER DATABASE DATAFILE &1 OFFLINE";
backup as copy datafile &1 format '+DATA';
switch datafile &1 to copy;
recover DATAFILE &1;
SQL "ALTER DATABASE DATAFILE &1 ONLINE";
delete noprompt copy of datafile &1;

dfn = 5;
export dfn;

SQL "ALTER DATABASE DATAFILE $dfn OFFLINE";
backup as copy datafile $dfn format '+DATA';
switch datafile $dfn to copy;
recover DATAFILE $dfn;
SQL "ALTER DATABASE DATAFILE $dfn ONLINE";
delete noprompt copy of datafile $dfn;
