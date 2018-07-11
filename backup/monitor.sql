prompt TABLE SPACE USAGE
@/home/oracle/tbspace

prompt ASM DISKS
@/home/oracle/asmdu

select name, HEADER_STATUS, STATE, PATH, OS_MB/1024 OS_GB, (TOTAL_MB-FREE_MB) as USED_MB, FREE_MB
  from V$ASM_DISK
 order by name;

@/home/oracle/logfile

@/home/oracle/status

prompt BACKUP LIST
@/home/oracle/backups

#exit
