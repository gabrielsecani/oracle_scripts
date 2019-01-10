--https://oracle-base.com/articles/misc/detect-and-correct-corruption

set lines 300 pages 30
col TABLESPACE_NAME for a15
col OWNER for a15
col SEGMENT_NAME for a25
select * from sys.cast_blocks_objects where file_id=30;
--TABLESPACE_NAME OWNER           SEGMENT_NAME              SEGMENT_TYPE          FILE_ID   BLOCK_ID

select * from v$database_block_corruption where file#=30;
--FILE#     BLOCK#     BLOCKS CORRUPTION_CHANGE# CORRUPTIO

COLUMN owner FORMAT A20
COLUMN segment_name FORMAT A30


SELECT DISTINCT owner, segment_name
FROM   v$database_block_corruption dbc
JOIN dba_extents e ON dbc.file# = e.file_id 
 AND dbc.block# BETWEEN e.block_id and e.block_id+e.blocks-1
where dbc.file# = 28 and block# = 2498284
ORDER BY 1,2;


SELECT DISTINCT owner, segment_name, file_id, file#, block#
FROM   v$database_block_corruption dbc
left JOIN sys.cast_blocks_objects e ON dbc.file# = e.file_id 
 AND dbc.block# BETWEEN e.block_id and e.block_id+(8*1024)-1
ORDER BY 1,2;


select * from dba_extents e where e.file_id=28 and e.block_id=540800

--others: 
--	https://support.oracle.com/epmos/faces/DocContentDisplay?_afrLoop=283323115879715&id=1088018.1&_afrWindowMode=0&_adf.ctrl-state=35lfh4mey_4
--	http://www.dba-oracle.com/t_repair_corrupt_blocks.htm

--DBMS_REPAIR
--Unlike the previous methods dicussed, the DBMS_REPAIR package allows you to detect and repair corruption. The process requires two administration tables to hold a list of corrupt blocks and index keys pointing to those blocks. These are created as follows.

BEGIN
  DBMS_REPAIR.admin_tables (
    table_name => 'REPAIR_TABLE',
    table_type => DBMS_REPAIR.repair_table,
    action     => DBMS_REPAIR.create_action,
    tablespace => 'PSAPSR3');

  DBMS_REPAIR.admin_tables (
    table_name => 'ORPHAN_KEY_TABLE',
    table_type => DBMS_REPAIR.orphan_table,
    action     => DBMS_REPAIR.create_action,
    tablespace => 'PSAPSR3');
END;
/

--With the administration tables built we are able to check the table of interest using the CHECK_OBJECT procedure.

SET SERVEROUTPUT ON
DECLARE
  v_num_corrupt INT;
BEGIN
  v_num_corrupt := 0;
  DBMS_REPAIR.check_object (
    schema_name       => 'SAPSR3',
    object_name       => 'MLKEPH',
    repair_table_name => 'REPAIR_TABLE',
    corrupt_count     =>  v_num_corrupt);
  DBMS_OUTPUT.put_line('number corrupt: ' || TO_CHAR (v_num_corrupt));
END;
/

--Assuming the number of corrupt blocks is greater than 0 the CORRUPTION_DESCRIPTION and the REPAIR_DESCRIPTION columns of the REPAIR_TABLE can be used to get more information about the corruption.
--At this point the currupt blocks have been detected, but are not marked as corrupt. The FIX_CORRUPT_BLOCKS procedure can be used to mark the blocks as corrupt, allowing them to be skipped by DML once the table is in the correct mode.

SET SERVEROUTPUT ON
DECLARE
  v_num_fix INT;
BEGIN
  v_num_fix := 0;
  DBMS_REPAIR.fix_corrupt_blocks (
    schema_name       => 'SAPSR3',
    object_name       => 'MLKEPH',
    object_type       => Dbms_Repair.table_object,
    repair_table_name => 'REPAIR_TABLE',
    fix_count         => v_num_fix);
  DBMS_OUTPUT.put_line('num fix: ' || TO_CHAR(v_num_fix));
END;
/

--Once the corrupt table blocks have been located and marked all indexes must be checked to see if any of their key entries point to a corrupt block. This is done using the DUMP_ORPHAN_KEYS procedure.
SET SERVEROUTPUT ON
DECLARE
  v_num_orphans INT;
BEGIN
  v_num_orphans := 0;
  DBMS_REPAIR.dump_orphan_keys (
    schema_name       => 'SCOTT',
    object_name       => 'PK_DEPT',
    object_type       => DBMS_REPAIR.index_object,
    repair_table_name => 'REPAIR_TABLE',
    orphan_table_name => 'ORPHAN_KEY_TABLE',
    key_count         => v_num_orphans);
  DBMS_OUTPUT.put_line('orphan key count: ' || TO_CHAR(v_num_orphans));
END;
/

--If the orphan key count is greater than 0 the index should be rebuilt.
--The process of marking the table block as corrupt automatically removes it from the freelists. This can prevent freelist access to all blocks following the corrupt block. To correct this the freelists must be rebuilt using the REBUILD_FREELISTS procedure.
BEGIN
  DBMS_REPAIR.rebuild_freelists (
    schema_name       => 'SAPSR3',
    object_name       => 'MLKEPH',
    object_type => DBMS_REPAIR.table_object);
END;
/

--The final step in the process is to make sure all DML statements ignore the data blocks marked as corrupt. This is done using the SKIP_CORRUPT_BLOCKS procedure.
BEGIN
  DBMS_REPAIR.skip_corrupt_blocks (
    schema_name       => 'SAPSR3',
    object_name       => 'MLKEPH',
    object_type => DBMS_REPAIR.table_object,
    flags       => DBMS_REPAIR.skip_flag);
END;
/
--The SKIP_CORRUPT column in the DBA_TABLES view indicates if this action has been successful.

--At this point the table can be used again but you will have to take steps to correct any data loss associated with the missing blocks.