select p.username, pname, count(*) qtde
    , sum(p.pga_used_mem)       /1024/1024/1024 pga_used_mem
    , sum(p.pga_alloc_mem)      /1024/1024/1024 pga_alloc_mem
    , sum(p.pga_freeable_mem)   /1024/1024/1024 pga_freeable_mem
    , sum(p.pga_max_mem)        /1024/1024/1024 pga_max_mem
from v$process p
group by rollup(p.username, pname)
/

select p.username, count(*) from v$process p
group by p.username
/

SELECT MACHINE, PROGRAM, COUNT(*) FROM V$SESSION GROUP BY MACHINE, PROGRAM order by 3;

PROMPT 
PROMPT Count the number of messages sent on behalf of parallel execution
SELECT NAME, VALUE FROM GV$SYSSTAT
  WHERE UPPER (NAME) LIKE '%PARALLEL OPERATIONS%'
  OR UPPER (NAME) LIKE '%PARALLELIZED%' OR UPPER (NAME) LIKE '%PX%';

PROMPT 
PROMPT Current wait state of each slave (child process) and query coordinator process on the system
SELECT px.SID "SID", p.PID, p.SPID "SPID", px.INST_ID "Inst",
       px.SERVER_GROUP "Group", px.SERVER_SET "Set",
       px.DEGREE "Degree", px.REQ_DEGREE "Req Degree", w.event "Wait Event"
FROM GV$SESSION s, GV$PX_SESSION px, GV$PROCESS p, GV$SESSION_WAIT w
WHERE s.sid (+) = px.sid AND s.inst_id (+) = px.inst_id AND
      s.sid = w.sid (+) AND s.inst_id = w.inst_id (+) AND
      s.paddr = p.addr (+) AND s.inst_id = p.inst_id (+)
ORDER BY DECODE(px.QCINST_ID,  NULL, px.INST_ID,  px.QCINST_ID), px.QCSID, 
DECODE(px.SERVER_GROUP, NULL, 0, px.SERVER_GROUP), px.SERVER_SET, px.INST_ID;

PROMPT 
PROMPT 
SELECT NAME, SUM(BYTES)/1024/1024 MBytes FROM V$SGASTAT WHERE UPPER(POOL)='SHARED POOL' 
  GROUP BY ROLLUP (NAME);
SELECT POOL, NAME, SUM(BYTES)/1024/1024 FROM V$SGASTAT WHERE POOL LIKE '%pool%'
  GROUP BY ROLLUP (POOL, NAME);