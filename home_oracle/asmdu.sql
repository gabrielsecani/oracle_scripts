set linesize 400
set pagesize 9999
SET VERIFY    off 

COLUMN name             FORMAT a12           HEAD 'Disk Group|Name'
COLUMN sector_size            FORMAT 99,999        HEAD 'Sector|Size'
COLUMN block_size             FORMAT 99,999        HEAD 'Block|Size'
COLUMN allocation_unit_size   FORMAT 999,999,999   HEAD 'Allocation|Unit Size'
COLUMN state                   FORMAT a11           HEAD 'State'
COLUMN type                    FORMAT a6            HEAD 'Type'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'Total Size (MB)'
COLUMN free_mb                FORMAT 999,999,999   HEAD 'Free Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'
COLUMN REQUIRED_MIRROR_FREE_MB for 999,999 HEAD 'Required|Mirror'
COLUMN USABLE_FILE_MB for 999,999,999 HEAD 'Usable file'
COLUMN PATH for a20

--break on report on disk_group_name skip 1
compute SUM LABEL "Grand Total: " of USED_MB FREE_MB TOTAL_MB on REPORT
break on report

select name, HEADER_STATUS, STATE, PATH, OS_MB/1024 OS_GB, (TOTAL_MB-FREE_MB) as USED_MB, FREE_MB from V$ASM_DISK
order by name;

SELECT
    name                                     name
  , sector_size                              sector_size
  , block_size                               block_size
  , allocation_unit_size                     allocation_unit_size
  , state                                    state
  , type                                     type
  , total_mb                                 total_mb  
  , (total_mb - free_mb)                     used_mb
  , free_mb                                  free_mb
  , ROUND((1- (free_mb / total_mb))*100, 2)  pct_used
  , REQUIRED_MIRROR_FREE_MB, USABLE_FILE_MB
FROM
    v$asm_diskgroup
ORDER BY name
/
