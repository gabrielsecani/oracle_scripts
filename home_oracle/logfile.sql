SET LINESIZE  200 PAGESIZE  40 feedback off

col DEST_ID for 99
col DEST_NAME for a20
col DESTINATION for a110
col TARGET for a10
col ARCHIVER for a8
col DB_UNIQUE_NAME for a10 heading "DBUNIQNAME"
col VALID_NOW for a9
col VALID_TYPE for a15
col COMPRESSION heading "COMPRES"
SELECT dest_id, DESTINATION FROM v$archive_dest where status != 'INACTIVE';
SELECT dest_id, dest_name, status, target, ARCHIVER, SCHEDULE, LOG_SEQUENCE, TRANSMIT_MODE, VALID_NOW, VALID_TYPE, DB_UNIQUE_NAME, COMPRESSION FROM v$archive_dest where status != 'INACTIVE';

COL GROUP#      FOR  99     HEADING 'Group'       JUSTIFY CENTER
COL THREAD#     FOR  99     HEADING 'Th#'      JUSTIFY CENTER
COL SEQUENCE#   FOR  999999 HEADING 'Seq.'        JUSTIFY  CENTER
COL TYPE        FOR  A8    HEADING 'Type'        JUSTIFY CENTER     
COL MEMBER      FOR  A45    HEADING 'Member Logfile'     JUSTIFY CENTER
COL MBYTES      FOR  99,999,999 HEADING 'Tam(MB)'  JUSTIFY  CENTER
COL STATUS      FOR  A10    HEADING 'Status|Group' JUSTIFY  CENTER
COL STATUS_FILE FOR  A10    HEADING 'Status|File'  JUSTIFY CENTER
compute sum of MBYTES on TYPE
break on TYPE  

SELECT
	 lf.GROUP#,
	 lg.THREAD#,
	 lg.SEQUENCE#,
	 lf.TYPE,
	 lf.MEMBER,
	 (lg.BYTES/1024/1024) MBYTES,
	 lf.STATUS,
	 lg.STATUS STATUS_FILE
FROM
	 v$logfile lf
JOIN v$log lg on lg.GROUP# = lf.GROUP#
UNION ALL
SELECT
		lf.GROUP#,
		lg.THREAD#,
		lg.SEQUENCE#,
		lf.TYPE,
		lf.MEMBER,
		(lg.BYTES/1024/1024) MBYTES,
		lf.STATUS,
		lg.STATUS STATUS_FILE
FROM
	 v$logfile lf
JOIN v$standby_log lg on lg.GROUP# = lf.GROUP#
ORDER BY
	TYPE,
	GROUP#,
	THREAD#,
	SEQUENCE#,
	MEMBER
/

set feedback on