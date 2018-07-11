CREATE TABLESPACE "PSAPSR3750" DATAFILE '+DATA' SIZE 15G AUTOEXTEND OFF;

ALTER TABLESPACE PSAPSR3750 ADD DATAFILE '+DATA' SIZE 22G AUTOEXTEND OFF,
'+DATA' SIZE 15G AUTOEXTEND OFF,
'+DATA' SIZE 15G AUTOEXTEND OFF,
'+DATA' SIZE 15G AUTOEXTEND OFF,
'+DATA' SIZE 15G AUTOEXTEND OFF
alter database datafile  4 resize 8G;
alter database datafile  5 resize 8G;
alter database datafile  6 resize 8G;
alter database datafile  7 resize 8G;
alter database datafile  8 resize 8G;
alter database datafile  9 resize 8G;
alter database datafile 10 resize 8G;
alter database datafile 11 resize 8G;
alter database datafile 12 resize 8G;
alter database datafile 13 resize 8G;
alter database datafile 14 resize 8G;
alter database datafile 15 resize 8G;
alter database datafile 16 resize 8G;
alter database datafile 17 resize 8G;
alter database datafile 18 resize 8G;
alter database datafile 19 resize 8G;
alter database datafile 20 resize 8G;
alter database datafile 21 resize 8G;
alter database datafile 22 resize 8G;
alter database datafile 23 resize 8G;
alter database datafile 24 resize 8G;
alter database datafile 25 resize 8G;
alter database datafile 20 resize 7G;
alter database datafile 21 resize 7G;
alter database datafile 22 resize 7G;
alter database datafile 23 resize 7G;
alter database datafile 24 resize 7G;
alter database datafile 25 resize 7G;
alter database datafile 26 resize 7G;
alter database datafile 27 resize 7G;
alter database datafile 28 resize 7G;
alter database datafile 29 resize 7G;
alter database datafile 30 resize 7G;
alter database datafile 31 resize 7G;
alter database datafile 32 resize 7G;
alter database datafile 33 resize 7G;
alter database datafile 34 resize 7G;
alter database datafile 35 resize 7G;
alter database datafile 36 resize 7G;
alter database datafile 37 resize 7G;
alter database datafile 38 resize 7G;
alter database datafile 39 resize 7G;
alter database datafile 40 resize 7G;
alter database datafile 41 resize 7G;
alter database datafile 42 resize 7G;
alter database datafile 43 resize 7G;

alter database datafile  4 resize 30G;
alter database datafile  5 resize 30G;
alter database datafile  6 resize 30G;
alter database datafile  7 resize 30G;
alter database datafile  8 resize 30G;
alter database datafile  9 resize 30G;
alter database datafile 10 resize 30G;
alter database datafile 11 resize 30G;
alter database datafile 12 resize 30G;
alter database datafile 13 resize 30G;
alter database datafile 14 resize 30G;
alter database datafile 15 resize 30G;
alter database datafile 16 resize 30G;
alter database datafile 17 resize 30G;
alter database datafile 18 resize 30G;
alter database datafile 19 resize 30G;
alter database datafile 20 resize 30G;
alter database datafile 21 resize 30G;
alter database datafile 22 resize 30G;
alter database datafile 23 resize 30G;
alter database datafile 24 resize 30G;
alter database datafile 25 resize 30G;
alter database datafile 26 resize 30G;
alter database datafile 27 resize 30G;
alter database datafile 28 resize 30G;
alter database datafile 29 resize 30G;
alter database datafile 30 resize 30G;
alter database datafile 31 resize 30G;


alter database datafile '+DATA/ED0B/DATAFILE/psapsr3750.278.976959295' resize 22G;
alter database datafile '+DATA/ED0B/DATAFILE/psapsr3750.261.976959455' resize 22G;
alter database datafile '+DATA/ED0B/DATAFILE/psapsr3750.361.976959483' resize 22G;
alter database datafile '+DATA/ED0B/DATAFILE/psapsr3750.350.976959511' resize 22G;
alter database datafile '+DATA/ED0B/DATAFILE/psapsr3750.365.976989681' resize 22G;

alter database drop datafile '+DATA/ED0B/DATAFILE/psapsr3750.365.976989681'
SQL "ALTER DATABASE DATAFILE 56 OFFLINE";
backup as copy datafile 56 format '+DATA';
switch datafile 56 to copy;
recover DATAFILE 56;
SQL "ALTER DATABASE DATAFILE 56 ONLINE";
delete noprompt copy of datafile 56;


alter database disable block change tracking;

alter database enable block change tracking using file '+ARCH';

begin
 dbms_stats.gather_table_stats(ownname=>'SAPSR3', tabname=>'WWWPARAMS', estimate_percent=>30, method_opt=>'FOR ALL COLUMNS SIZE 1', cascade=>TRUE, no_invalidate=>FALSE);
 dbms_stats.gather_table_stats(ownname=>'SAPSR3', tabname=>'WWWLANGRES', method_opt=>'FOR ALL COLUMNS SIZE 1', cascade=>TRUE, no_invalidate=>FALSE);
 dbms_stats.gather_table_stats(ownname=>'SAPSR3', tabname=>'WWWDATA', estimate_percent=>30, method_opt=>'FOR ALL COLUMNS SIZE 1', cascade=>TRUE, no_invalidate=>FALSE);
 dbms_stats.gather_table_stats(ownname=>'SAPSR3', tabname=>'WSSOAPPROP', method_opt=>'FOR ALL COLUMNS SIZE 1', cascade=>TRUE, no_invalidate=>FALSE);
 dbms_stats.gather_table_stats(ownname=>'SAPSR3', tabname=>'WSHEADER', method_opt=>'FOR ALL COLUMNS SIZE 1', cascade=>TRUE, no_invalidate=>FALSE);
 dbms_stats.gather_table_stats(ownname=>'SAPSR3', tabname=>'WSD_PRICE_ELEM_T', method_opt=>'FOR ALL COLUMNS SIZE 1', cascade=>TRUE, no_invalidate=>FALSE);
 dbms_stats.gather_table_stats(ownname=>'SAPSR3', tabname=>'WSDT_MAT_LAYOUT', method_opt=>'FOR ALL COLUMNS SIZE 1', cascade=>TRUE, no_invalidate=>FALSE);
 dbms_stats.gather_table_stats(ownname=>'SAPSR3', tabname=>'WSDT_CBP_DHTEXT', method_opt=>'FOR ALL COLUMNS SIZE 1', cascade=>TRUE, no_invalidate=>FALSE);
 dbms_stats.gather_table_stats(ownname=>'SAPSR3', tabname=>'WRF_PRICAT_PROCT', method_opt=>'FOR ALL COLUMNS SIZE 1', cascade=>TRUE, no_invalidate=>FALSE);
end;

BEGIN dbms_stats.gather_schema_stats('SAPSR3'); END;

SELECT *
FROM   DBA_AUTOTASK_CLIENT
WHERE  CLIENT_NAME = 'auto optimizer stats collection';

