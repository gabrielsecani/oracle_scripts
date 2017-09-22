DEV1:
sga_max_size                         big integer 9504M
sga_target                           big integer 9504M
ED0.__pga_aggregate_target=1316487168
ED0.__sga_target=2925527040
*.shared_pool_size=3478923509 (3328M)

QA1:
*.shared_pool_size=3872M
*.pga_aggregate_target=8117488188


alter system set sga_max_size = 3G scope=spfile;
alter system set sga_target = 3632M scope=spfile;

alter system set pga_aggregate_target = 14G scope=spfile;
alter system set shared_pool_size = 9G scope=spfile;
alter system set db_cache_size = 10G scope=spfile;


!vi /oracle/EP0/11204/dbs/initEP0.ora
startup pfile=/oracle/EP0/11204/dbs/initEP0.ora nomount
create spfile from pfile;
shutdown immediate;
startup;

--addr
         "db_cache_size" to 8448 M.


ED0.__pga_aggregate_target=1316487168
ED0.__sga_target=2925527040


tar c /oracle/grid.tar /oracle/EQ0/11204/grid/product/11.2.0/grid

tar c /oracle/grid.tar /oracle/EQ0/11204/grid/product/11.2.0/grid/
tar c /oracle/grid.tar -C /oracle/EQ0/11204/grid/
gzip /oracle/grid.tar &


A) How To Relink The Oracle Grid Infrastructure Standalone (Restart) Installation.

In order to relink the Oracle Grid Infrastructure Standalone (Restart) Installation (Non-RAC), please follow the next steps:

1) Stop the OHAS stack (as “grid” OS user):
 grid@dbaasm ~]$ id
uid=1100(grid) gid=1000(oinstall) groups=1000(oinstall),1100(asmadmin),1200(dba),1300(asmdba),1301(asmoper)

[grid@dbaasm ~]$ . oraenv
ORACLE_SID = [+ASM] ? +ASM
The Oracle base remains unchanged with value /u01/app/grid

[grid@dbaasm ~]$ crsctl stop has
CRS-2791: Starting shutdown of Oracle High Availability Services-managed resources on 'dbaasm'
CRS-2673: Attempting to stop 'ora.SPFILE.dg' on 'dbaasm'
CRS-2673: Attempting to stop 'ora.db1.db' on 'dbaasm'
CRS-2673: Attempting to stop 'ora.LISTENER.lsnr' on 'dbaasm'
CRS-2677: Stop of 'ora.LISTENER.lsnr' on 'dbaasm' succeeded
CRS-2677: Stop of 'ora.db1.db' on 'dbaasm' succeeded
CRS-2673: Attempting to stop 'ora.DATA.dg' on 'dbaasm'
CRS-2673: Attempting to stop 'ora.RECO.dg' on 'dbaasm'
CRS-2677: Stop of 'ora.DATA.dg' on 'dbaasm' succeeded
CRS-2677: Stop of 'ora.RECO.dg' on 'dbaasm' succeeded
CRS-2677: Stop of 'ora.SPFILE.dg' on 'dbaasm' succeeded
CRS-2673: Attempting to stop 'ora.asm' on 'dbaasm'
CRS-2677: Stop of 'ora.asm' on 'dbaasm' succeeded
CRS-2673: Attempting to stop 'ora.cssd' on 'dbaasm'
CRS-2677: Stop of 'ora.cssd' on 'dbaasm' succeeded
CRS-2673: Attempting to stop 'ora.evmd' on 'dbaasm'
CRS-2677: Stop of 'ora.evmd' on 'dbaasm' succeeded
CRS-2793: Shutdown of Oracle High Availability Services-managed resources on 'dbaasm' has completed
CRS-4133: Oracle High Availability Services has been stopped.


2) Connect as root user (different session) and unlock the Oracle Grid Infrastructure Standalone installation as follows:


[grid@dbaasm ~]$ su -
Password: 
[root@dbaasm ~]# id

uid=0(root) gid=0(root) groups=0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),10(wheel)

[root@dbaasm ~]# . oraenv
ORACLE_SID = [root] ? +ASM
The Oracle base has been set to /u01/app/grid
---- 
export ORACLE_BASE=/oracle
export ORACLE_HOME=/oracle/EQ0/11204/grid/product/11.2.0/grid
export ORACLE_SID=+ASM
export ORACLE_BIN=$ORACLE_HOME/bin
----

[root@dbaasm ~]# $ORACLE_HOME/crs/install/roothas.pl -unlock
Using configuration parameter file: /u01/app/grid/product/11.2.0/grid/crs/install/crsconfig_params

Successfully unlock /u01/app/grid/product/11.2.0/grid



3) Then relink the Oracle Grid Infrastructure Standalone installation as follows (as grid user):

3.1) First of all, rename the $ORACLE_HOME/rdbms/lib/config.o file (located at the Oracle Grid Infrastructure Standalone installation) to force a regeneration:


[grid@dbaasm ~]$ ls -l $ORACLE_HOME/rdbms/lib/config.o 
-rw-r--r-- 1 grid oinstall 1256 Sep 18 23:03 /u01/app/grid/product/11.2.0/grid/rdbms/lib/config.o

[grid@dbaasm ~]$ mv $ORACLE_HOME/rdbms/lib/config.o $ORACLE_HOME/rdbms/lib/config.o_BAK

[grid@dbaasm ~]$ ls -l $ORACLE_HOME/rdbms/lib/config.o*
-rw-r--r-- 1 grid oinstall 1256 Sep 18 23:03 /u01/app/grid/product/11.2.0/grid/rdbms/lib/config.o_BAK

3.2) Then relink the the Oracle Grid Infrastructure Standalone installation:



[grid@dbaasm ~]$ script /tmp/relink_gi.txt
Script started, file is /tmp/relink_gi.txt
[grid@dbaasm ~]$ 
[grid@dbaasm ~]$ id
uid=1100(grid) gid=1000(oinstall) groups=1000(oinstall),1100(asmadmin),1200(dba),1300(asmdba),1301(asmoper)

[grid@dbaasm ~]$ env| egrep 'ORA|PATH' | sort
LD_LIBRARY_PATH=/oracle/grid/lib
ORACLE_BASE=/oracle
ORACLE_HOME=/oracle/ED0/grid
ORACLE_SID=+ASM
PATH=/usr/lib64/qt-3.3/bin:/usr/NX/bin:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/home/grid/bin:.:$ORACLE_BIN

[grid@dbaasm ~]$ $ORACLE_HOME/bin/relink all

writing relink log to: /u01/app/grid/product/11.2.0/grid/install/relink.log


[grid@dbaasm ~]$ exit
exit
Script done, file is /tmp/relink_gi.txt


4) Connect as root user (different session) and lock back the Oracle Grid Infrastructure Standalone installation as follows:



[grid@dbaasm ~]$ su - 
Password: 
[root@dbaasm ~]# . oraenv
ORACLE_SID = [root] ? +ASM
The Oracle base has been set to /u01/app/grid


[root@dbaasm ~]# $ORACLE_HOME/rdbms/install/rootadd_rdbms.sh
 

[grid@dbaasm ~]$ su - 
Password: 
[root@dbaasm ~]# . oraenv
ORACLE_SID = [root] ? +ASM
The Oracle base has been set to /u01/app/grid


[root@dbaasm ~]# $ORACLE_HOME/crs/install/roothas.pl -patch
Using configuration parameter file: /u01/app/grid/product/11.2.0/grid/crs/install/crsconfig_params
CRS-4123: Oracle High Availability Services has been started.