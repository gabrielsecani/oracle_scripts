@inst

set linesize 400
set pagesize 9999
col DB_UNIQUE_NAME for a15

PROMPT Database Status
SELECT DB_UNIQUE_NAME, OPEN_MODE, DATABASE_ROLE, SWITCHOVER_STATUS, FLASHBACK_ON
 FROM v$database;

archive log list;

