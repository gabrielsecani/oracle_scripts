find --type controlfile + *
ls -s + *cntrled0.dbf

alter system set control_files='+DATA/ED0/cntrled0.dbf', '+ARCH/ED0/cntrlED0.dbf' scope=spfile;

mkalias +ARCH/ED0B/CONTROLFILE/current.298.943705187 +ARCH/ed0/cntrled0.dbf

mkalias +DATA/ED0B/CONTROLFILE/current.349.952857279 +DATA/ED0/cntrled0.dbf
mkalias +DATA/ED0B/CONTROLFILE/current.309.943705185 +DATA/ed0/cntrled0.dbf

startup nomount pfile=/oracle/ED0/11204/dbs/initED0.ora 
alter database backup controlfile to trace as '/home/oracle/cntrlEP0.dbf';


configure controlfile autobackup on;

BR2007W Control file '+DATA/ASM/CONTROLFILE/cntrled0.dbf.bkp.265.936113895' is not an ASM alias (standard name '+DATA/ED0A/cntrlED0.dbf') or is not part of database ED0A

BR2007W Control file '+ARCH/ASM/CONTROLFILE/cntrled0.dbf.bkp.261.936113959' is not an ASM alias (standard name '+ARCH/ED0A/cntrlED0.dbf') or is not part of database ED0A

