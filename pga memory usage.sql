alter system set shared_pool_size=0 scope=both;
alter system set java_pool_size=64M scope=both;
alter system set large_pool_size=64M scope=both;

alter system set shared_pool_size=600M
alter system set sga_min_size = 1G scope=both;


col name for a45
col value for 999,999.999
select NAME,
	case when UNIT='bytes' then VALUE/1024/1024 else value end VALUE, 
	case when UNIT='bytes' then 'Mbytes' else UNIT end UNIT,
	con_id
  FROM V$PGASTAT;
  
select CATEGORY, count(distinct pid), sum(ALLOCATED)/1024/1024 ALLOCATED_MB, sum(USED)/1024/1024 USED_MB, sum(MAX_ALLOCATED)/1024/1024 MAX_ALLOCATED_MB
from V$PROCESS_MEMORY
group by CATEGORY;

SELECT low_optimal_size/1024 low_kb,
       (high_optimal_size+1)/1024 high_kb,
       optimal_executions, onepass_executions, multipasses_executions
  FROM V$SQL_WORKAREA_HISTOGRAM
 WHERE total_executions != 0;
 
 -- work active
 SELECT TO_NUMBER(DECODE(sid, 65535, null, sid)) sid,
       operation_type operation,
       TRUNC(expected_size/1024) esize,
       TRUNC(actual_mem_used/1024) mem,
       TRUNC(max_mem_used/1024) "max mem",
       number_passes pass,
       TRUNC(TEMPSEG_SIZE/1024) tsize
  FROM V$SQL_WORKAREA_ACTIVE
 ORDER BY 1,2;

 
-- The following query finds the top 10 work areas that require the most cache memory:
col OPERATION_TYPE for a15
col POLICY for a15
SELECT *
FROM   (SELECT workarea_address, operation_type, policy, estimated_optimal_size, address, hash_value
        FROM V$SQL_WORKAREA                                                      
        ORDER BY estimated_optimal_size DESC)
 WHERE ROWNUM <= 10;
 
-- The following query finds the cursors with one or more work areas that have been executed in one or multiple passes:

col sql_text format A80 wrap 
SELECT sql_text, sum(ONEPASS_EXECUTIONS) onepass_cnt,
       sum(MULTIPASSES_EXECUTIONS) mpass_cnt, wa.address, wa.hash_value
FROM V$SQL s, V$SQL_WORKAREA wa 
WHERE s.address = wa.address 
GROUP BY sql_text, wa.address, wa.hash_value
HAVING sum(ONEPASS_EXECUTIONS+MULTIPASSES_EXECUTIONS)>0;

-- Using the hash value and address of a particular cursor, the following query displays the cursor execution plan, including information about the associated work areas:

col "O/1/M" format a10
col name format a20
col OPERATION format a20
col OPTIONS format a20
SELECT operation, options, object_name name, trunc(bytes/1024/1024) "input(MB)",
       TRUNC(last_memory_used/1024) last_mem,
       TRUNC(estimated_optimal_size/1024) optimal_mem, 
       TRUNC(estimated_onepass_size/1024) onepass_mem, 
       DECODE(optimal_executions, null, null, 
              optimal_executions||'/'||onepass_executions||'/'||
              multipasses_executions) "O/1/M"
  FROM V$SQL_PLAN p, V$SQL_WORKAREA w 
 WHERE p.address=w.address(+) 
   AND p.hash_value=w.hash_value(+) 
   AND p.id=w.operation_id(+) 
   AND p.address='&address'
   AND p.hash_value=&hash_value; 

   
-- memory by session 
col session for a30
SELECT to_char(ssn.sid, '9999') || ' - ' || nvl(ssn.username, nvl(bgp.name, 'background')) ||
nvl(lower(ssn.machine), ins.host_name) "SESSION",
to_char(prc.spid, '999999999') "PID/THREAD",
to_char((se1.value/1024)/1024, '999G999G990D00') || ' MB' " CURRENT SIZE",
to_char((se2.value/1024)/1024, '999G999G990D00') || ' MB' " MAXIMUM SIZE"
FROM v$sesstat se1, v$sesstat se2, v$session ssn, v$bgprocess bgp, v$process prc,
v$instance ins, v$statname stat1, v$statname stat2
WHERE se1.statistic# = stat1.statistic# and stat1.name = 'session pga memory'
AND se2.statistic# = stat2.statistic# and stat2.name = 'session pga memory max'
AND se1.sid = ssn.sid
AND se2.sid = ssn.sid
AND ssn.paddr = bgp.paddr (+)
AND ssn.paddr = prc.addr (+);