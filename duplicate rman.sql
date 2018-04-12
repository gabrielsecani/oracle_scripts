connect TARGET SYS/DRSAP01EP0@EP0B 
connect AUXILIARY SYS/DRSAP01EP0@EP0SB

rman TARGET SYS/DRSAP01EP0@EP0B AUXILIARY SYS/DRSAP01EP0@EP0SB

duplicate target database to EP0 from active database 
using COMPRESSED BACKUPSET;


rman TARGET / AUXILIARY SYS/DRSAP01EP0@EP0SB

DUPLICATE TARGET DATABASE
  FOR STANDBY
  FROM ACTIVE DATABASE
  DORECOVER
  NOFILENAMECHECK;
}

run{
ALLOCATE AUXILIARY CHANNEL cb1 DEVICE TYPE DISK;
ALLOCATE CHANNEL ca1 DEVICE TYPE DISK;
ALLOCATE AUXILIARY CHANNEL cb2 DEVICE TYPE DISK;
ALLOCATE CHANNEL ca2 DEVICE TYPE DISK;
DUPLICATE TARGET DATABASE
  FOR STANDBY
  FROM ACTIVE DATABASE 
  DORECOVER
  NOFILENAMECHECK;
}

catalog start with '/oracle/arch/*';
 
catalog backuppiece '/oracle/arch/arc_EP0_20180408_e15746_s5627_p1_c1_ufrsvqjdd';
catalog backuppiece '/oracle/arch/arc_EP0_20180408_e15751_s5628_p1_c1_ufssvqjdd';
catalog backuppiece '/oracle/arch/arc_EP0_20180408_e15752_s5630_p1_c1_ufusvr8ge';
catalog backuppiece '/oracle/arch/arc_EP0_20180408_e15753_s5631_p1_c1_ufvsvr8ge';
catalog backuppiece '/oracle/arch/arc_EP0_20180408_e15756_s5654_p1_c1_ugmsvrtjd';
catalog backuppiece '/oracle/arch/arc_EP0_20180408_e15759_s5655_p1_c1_ugnsvrtjd';
catalog backuppiece '/oracle/arch/arc_EP0_20180408_e15760_s5656_p1_c1_ugosvrtk7';
catalog backuppiece '/oracle/arch/arc_EP0_20180409_e15770_s5675_p1_c1_uhbsvt7pe';
catalog backuppiece '/oracle/arch/arc_EP0_20180409_e15780_s5676_p1_c1_uhcsvt7pe';
catalog backuppiece '/oracle/arch/arc_EP0_20180409_e15781_s5677_p1_c1_uhdsvt7t1';
catalog backuppiece '/oracle/arch/arc_EP0_20180409_e15797_s5751_p1_c1_ujnsvtr6r';
catalog backuppiece '/oracle/arch/arc_EP0_20180409_e15815_s5752_p1_c1_ujosvtr6s';
catalog backuppiece '/oracle/arch/arc_EP0_20180409_e15817_s5754_p1_c1_ujqsvtssd';
catalog backuppiece '/oracle/arch/arc_EP0_20180409_e15820_s5755_p1_c1_ujrsvtssd';

restore archivelog sequence 15820;


dgmgrl SYS/DRSAP01EP0@EP0A <<!
show configuration verbose
exit
!

sp <<!
@tbspace
@tablespace
!
sp <<!
@asmdu
@asmdisks
@status
!

