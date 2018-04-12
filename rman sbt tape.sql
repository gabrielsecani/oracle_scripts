
allocate channel for delete device type SBT_TAPE parms 'SBT_LIBRARY=/usr/omni/lib/libob2oracle8_64bit.a';

 send device type 'sbt_tape' 'OB2BARHOSTNAME=sapqa2.raiadrogasil.com.br';
 send channel 'c1' 'OB2BARTYPE=Oracle8';
 send channel 'c1' 'OB2APPNAME=EQ0';
crosscheck backup tag TAG20180118T120617
 allocate channel for delete device type SBT_TAPE parms 'SBT_LIBRARY=/usr/omni/lib/libob2oracle8_64bit.a';

RUN {
 allocate channel 'c1' type 'sbt_tape' parms 'SBT_LIBRARY=/usr/omni/lib/libob2oracle8_64bit.a';
 send device type 'sbt_tape' 'OB2BARHOSTNAME=sapqa2.raiadrogasil.com.br';
 send channel 'c1' 'OB2BARTYPE=Oracle8';
 send channel 'c1' 'OB2APPNAME=EQ0';
 delete force backup device type sbt_tape;
}

run {
 allocate channel 'c1' type 'sbt_tape' parms 'SBT_LIBRARY=/usr/omni/lib/libob2oracle8_64bit.a';
 send device type 'sbt_tape' 'OB2BARHOSTNAME=sapdev2.raiadrogasil.com.br';
 send channel 'c1' 'OB2BARTYPE=Oracle8';
 send channel 'c1' 'OB2APPNAME=ED0';

 delete backup of controlfile device type sbt_tape;
}

run {
 allocate channel 'd1' device type disk;
 delete obsolete device type disk;
}

run {
 allocate channel 'c1' type 'sbt_tape' parms 'SBT_LIBRARY=/usr/omni/lib/libob2oracle8_64bit.a';
 send device type 'sbt_tape' 'OB2BARHOSTNAME=sapdev2.raiadrogasil.com.br';
 send channel 'c1' 'OB2BARTYPE=Oracle8';
 send channel 'c1' 'OB2APPNAME=ED0';
 delete obsolete device type sbt_tape;
}

run {
 allocate channel 'c1' type 'sbt_tape' parms 'SBT_LIBRARY=/usr/omni/lib/libob2oracle8_64bit.a';
 send device type 'sbt_tape' 'OB2BARHOSTNAME=sapdev2.raiadrogasil.com.br';
 send channel 'c1' 'OB2BARTYPE=Oracle8';
 send channel 'c1' 'OB2APPNAME=ED0';
 delete force backup device type sbt_tape;
}

run {
 allocate channel 'c1' type 'sbt_tape' parms 'SBT_LIBRARY=/usr/omni/lib/libob2oracle8_64bit.a';
 delete backup device type sbt_tape;
}

 backup of controlfile device type sbt_tape

CONFIGURE DEVICE TYPE 'SBT_TAPE' BACKUP TYPE TO COMPRESSED BACKUPSET PARALLELISM 1;
CONFIGURE CHANNEL DEVICE TYPE sbt PARMS='SBT_LIBRARY=/usr/omni/lib/libob2oracle8_64bit.a';

 
RUN {
 allocate channel 'c1' type 'sbt_tape' parms 'SBT_LIBRARY=/usr/omni/lib/libob2oracle8_64bit.a';
  CROSSCHECK BACKUP device type sbt_tape;
}


RUN {
 allocate channel 'c1' type 'sbt_tape' parms 'SBT_LIBRARY=/usr/omni/lib/libob2oracle8_64bit.a';
 send device type 'sbt_tape' 'OB2BARHOSTNAME=sapprod1.raiadrogasil.com.br';
 send channel 'c1' 'OB2BARTYPE=Oracle8';
 send channel 'c1' 'OB2APPNAME=EP0';
 list backup device type sbt_tape;
}
delete backup device type disk