select usn, state, undoblockstotal "Total", undoblocksdone "Done", undoblockstotal-undoblocksdone "ToDo", 
             decode(cputime,0,'unknown',sysdate+(((undoblockstotal-undoblocksdone) / (undoblocksdone / cputime)) / 86400))
              "Estimated time to complete" 
   from v$fast_start_transactions;

select a.sid, USED_UBLK, USED_UREC, START_SCNB
    from v$session a, v$transaction b
    where rawtohex(a.saddr) = rawtohex(b.ses_addr);

	-- current running transactions
SELECT start_time,
       used_ublk,
       used_urec,
       s.SID,
       s.serial#,
       s.username,
       s.program
 FROM v$transaction t
 join v$session s on s.taddr = t.addr;

select nvl(USERNAME, 'TOTAL') USERNAME, PROGRAM, sum(PGA_USED_MEM)/1024/1024/1024 PGA_USED_MEM, sum(PGA_MAX_MEM)/1024/1024/1024 PGA_MAX_MEM
from v$process
group by cube((USERNAME, PROGRAM));

select userenv('sid') from dual