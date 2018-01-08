sqlplus /nolog

connect sys/DRSAP01ED0@sapdev1:1527/ED0 as sysdba 
set lines 999
select host_name from v$instance;
select * from v$license;
connect sys/DRSAP01ED0@sapdev2:1527/ED0 as sysdba 
set lines 999
select host_name from v$instance;
select * from v$license;

connect sys/DRSAP01EQ0@sapqa1:1527/EQ0 as sysdba 
set lines 999
select host_name from v$instance;
select * from v$license;
connect sys/DRSAP01EQ0@sapqa2:1527/EQ0 as sysdba 
set lines 999
select host_name from v$instance;
select * from v$license;

connect sys/DRSAP01EP0@sapprod1:1527/EP0 as sysdba 
set lines 999
select host_name from v$instance;
select * from v$license;
connect sys/DRSAP01EP0@sapprod2:1527/EP0 as sysdba 
set lines 999
select host_name from v$instance;
select * from v$license;

select owner, object_name, SUBOBJECT_NAME, OBJECT_TYPE
from all_objects where object_name like '%VERS%' and OWNER != 'SAPSR3'
order by 1,2,3;

select * from V$OPTION;
select * from V$SQL_FEATURE;
select * from V$VERSION;

col DESCRIPTION for a60
col NAME for a32
col VALUE for a32
select name, DESCRIPTION, value
from v$parameter 
where name like '%cpu%' or name like 'db_unique_name';


SAPDEV1
SESSIONS_MAX SESSIONS_WARNING SESSIONS_CURRENT SESSIONS_HIGHWATER  USERS_MAX CPU_COUNT_CURRENT CPU_CORE_COUNT_CURRENT CPU_SOCKET_COUNT_CURRENT CPU_COUNT_HIGHWATER CPU_CORE_COUNT_HIGHWATER CPU_SOCKET_COUNT_HIGHWATER
------------ ---------------- ---------------- ------------------ ---------- ----------------- ---------------------- ------------------------ ------------------- ------------------------ --------------------------
           0                0               34                 45          0                 8                      2                                            8                        2
SAPDEV2
SESSIONS_MAX SESSIONS_WARNING SESSIONS_CURRENT SESSIONS_HIGHWATER  USERS_MAX CPU_COUNT_CURRENT CPU_CORE_COUNT_CURRENT CPU_SOCKET_COUNT_CURRENT CPU_COUNT_HIGHWATER CPU_CORE_COUNT_HIGHWATER CPU_SOCKET_COUNT_HIGHWATER
------------ ---------------- ---------------- ------------------ ---------- ----------------- ---------------------- ------------------------ ------------------- ------------------------ --------------------------
           0                0               19                 28          0                 8                      2                                            8                        2

sapqa1
SESSIONS_MAX SESSIONS_WARNING SESSIONS_CURRENT SESSIONS_HIGHWATER  USERS_MAX CPU_COUNT_CURRENT CPU_CORE_COUNT_CURRENT CPU_SOCKET_COUNT_CURRENT CPU_COUNT_HIGHWATER CPU_CORE_COUNT_HIGHWATER CPU_SOCKET_COUNT_HIGHWATER
------------ ---------------- ---------------- ------------------ ---------- ----------------- ---------------------- ------------------------ ------------------- ------------------------ --------------------------
           0                0               42                 57          0                 8                      2                                            8                        2
sapqa2
SESSIONS_MAX SESSIONS_WARNING SESSIONS_CURRENT SESSIONS_HIGHWATER  USERS_MAX CPU_COUNT_CURRENT CPU_CORE_COUNT_CURRENT CPU_SOCKET_COUNT_CURRENT CPU_COUNT_HIGHWATER CPU_CORE_COUNT_HIGHWATER CPU_SOCKET_COUNT_HIGHWATER
------------ ---------------- ---------------- ------------------ ---------- ----------------- ---------------------- ------------------------ ------------------- ------------------------ --------------------------
           0                0               19                 31          0                 8                      2                                            8                        2

sapprod1
SESSIONS_MAX SESSIONS_WARNING SESSIONS_CURRENT SESSIONS_HIGHWATER  USERS_MAX CPU_COUNT_CURRENT CPU_CORE_COUNT_CURRENT CPU_SOCKET_COUNT_CURRENT CPU_COUNT_HIGHWATER CPU_CORE_COUNT_HIGHWATER CPU_SOCKET_COUNT_HIGHWATER
------------ ---------------- ---------------- ------------------ ---------- ----------------- ---------------------- ------------------------ ------------------- ------------------------ --------------------------
           0                0              103                143          0                32                      8                                           32                        8
sapprod2
SESSIONS_MAX SESSIONS_WARNING SESSIONS_CURRENT SESSIONS_HIGHWATER  USERS_MAX CPU_COUNT_CURRENT CPU_CORE_COUNT_CURRENT CPU_SOCKET_COUNT_CURRENT CPU_COUNT_HIGHWATER CPU_CORE_COUNT_HIGHWATER CPU_SOCKET_COUNT_HIGHWATER
------------ ---------------- ---------------- ------------------ ---------- ----------------- ---------------------- ------------------------ ------------------- ------------------------ --------------------------
           0                0               33                 44          0                24                      6                                           24                        6
SQL> select * from V$OPTION;

PARAMETER                                                        VALUE
---------------------------------------------------------------- ----------------------------------------------------------------
Partitioning                                                     TRUE
Objects                                                          TRUE
Real Application Clusters                                        FALSE
Advanced replication                                             TRUE
Bit-mapped indexes                                               TRUE
Connection multiplexing                                          TRUE
Connection pooling                                               TRUE
Database queuing                                                 TRUE
Incremental backup and recovery                                  TRUE
Instead-of triggers                                              TRUE
Parallel backup and recovery                                     TRUE
Parallel execution                                               TRUE
Parallel load                                                    TRUE
Point-in-time tablespace recovery                                TRUE
Fine-grained access control                                      TRUE
Proxy authentication/authorization                               TRUE
Change Data Capture                                              TRUE
Plan Stability                                                   TRUE
Online Index Build                                               TRUE
Coalesce Index                                                   TRUE
Managed Standby                                                  TRUE
Materialized view rewrite                                        TRUE
Database resource manager                                        TRUE
Spatial                                                          TRUE
Automatic Storage Management                                     TRUE
Export transportable tablespaces                                 TRUE
Transparent Application Failover                                 TRUE
Fast-Start Fault Recovery                                        TRUE
Sample Scan                                                      TRUE
Duplexed backups                                                 TRUE
Java                                                             TRUE
OLAP Window Functions                                            TRUE
Block Media Recovery                                             TRUE
Fine-grained Auditing                                            TRUE
Application Role                                                 TRUE
Enterprise User Security                                         TRUE
Oracle Data Guard                                                TRUE
Oracle Label Security                                            FALSE
OLAP                                                             TRUE
Basic Compression                                                TRUE
Join index                                                       TRUE
Trial Recovery                                                   TRUE
Data Mining                                                      TRUE
Online Redefinition                                              TRUE
Streams Capture                                                  TRUE
File Mapping                                                     TRUE
Block Change Tracking                                            TRUE
Flashback Table                                                  TRUE
Flashback Database                                               TRUE
Transparent Data Encryption                                      TRUE
Backup Encryption                                                TRUE
Unused Block Compression                                         TRUE
Oracle Database Vault                                            FALSE
Result Cache                                                     TRUE
SQL Plan Management                                              TRUE
SecureFiles Encryption                                           TRUE
Real Application Testing                                         TRUE
Flashback Data Archive                                           TRUE
DICOM                                                            TRUE
Active Data Guard                                                TRUE
Server Flash Cache                                               TRUE
Advanced Compression                                             TRUE
XStream                                                          TRUE
Deferred Segment Creation                                        TRUE
Data Redaction                                                   TRUE

65 rows selected.


scp ./tbspace.sql oracle@sapqa1:/home/oracle

ssh oracle@sapdev1
DRSAP01EQ0
DRSAP01EP0
DRSAP01ED0

