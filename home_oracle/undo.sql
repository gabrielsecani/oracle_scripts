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
 FROM v$transaction t, v$session s  WHERE s.taddr = t.addr;
