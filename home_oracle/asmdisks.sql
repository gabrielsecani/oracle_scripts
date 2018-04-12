set LINESIZE 999
COL PATH for A18
COL name for A12
COL REQUIRED_MIRROR_FREE_MB for 999,999 HEAD 'Required'
COL USABLE_FILE_MB for 999,999,999 HEAD 'Usable file'
COL TOTAL_MB for 999,999,999
COL FREE_MB for 999,999,999
COL USED_MB for 999,999,999
COL OS_GB for 9,999
select name, STATE, TOTAL_MB, FREE_MB, TOTAL_MB-FREE_MB as USED_MB, REQUIRED_MIRROR_FREE_MB, USABLE_FILE_MB from V$ASM_DISKGROUP
order by name;

compute SUM LABEL "Grand Total: " of TOTAL_MB USED_MB on REPORT
select name, HEADER_STATUS, STATE, PATH, OS_MB/1024 OS_GB, (TOTAL_MB-FREE_MB) as USED_MB, FREE_MB from V$ASM_DISK
order by name;

/*
--alter diskgroup arch add disk '/dev/rhdisk5ASM';
--ALTER DISKGROUP data DROP DISK DATA_0003;
--ALTER DISKGROUP arch DROP DISK ARCH_0000;
--alter diskgroup data add disk '/dev/rhdisk4ASM';

-- iniciar serviço asm.

srvctl status asm
srvctl start asm
srvctl stop asm

crsctl stop has
crsctl start has
crsctl status has

-- verificar servicos do asm
crsctl status resource -t -init
crsctl status resource ora.cssd
crsctl start resource ora.cssd

crsctl start resource ora.diskmon


cp +ARCH/eq0/oraarch/1_60200_940436451.dbf sys/DRSAP01EQ0@sapqa2.1521.+ASM:/

DRSAP01EQ0


cp +ARCH/eq0/oraarch/1_601* /migracao/arch/

cp /migracao/arch/1_60157_940436451.dbf +ARCH/eq0/oraarch/

alter database register logfile '+ARCH/eq0/oraarch/1_60158_940436451.dbf';

alter database register logfile '';
*/