#!/bin/sh

export SQLP="sqlplus -s / as sysdba"
export SET="set pages 0 trims on lines 2000 echo off ver off head off feed off"
 
 
export ASM_RUNNING=$(ps -ef |grep -i asm_pmon |awk {'print $8'} |sed "s/asm_pmon_//g" |egrep -v "sed|grep")
[ "$ASM_RUNNING" != "" ] && ASM_INSTANCE=$(echo $ASM_RUNNING |sed '$s/.$//')
 
LISTENER_LOG=$ORACLE_BASE/diag/tnslsnr/$(hostname -s)/listener/trace/listener.log
 
function diag {
export DIAG_DEST=$(
echo "
$SET
select value from v\$diag_info where name='Diag Trace';" |$SQLP )
}

diag;

echo $DIAG_DEST
sleep 2
#LISTENER_LOG=$ORACLE_BASE/diag/tnslsnr/$(hostname -s)/listener/trace/listener.log
# /oracle/EQ0/saptrace/diag/tnslsnr/sapqa2

for die1 in `ps -ef | grep -i tail | grep -v grep | awk '{print $2}' `
do 
  kill ${die1}
done

for lsnr in `find /oracle/$ORACLE_SID -name listener.log`
do
  ls -l ${lsnr}
  tail -f ${lsnr}&
done

ALERT_LOG=$DIAG_DEST/alert_$ORACLE_SID.log
DG_LOG=$DIAG_DEST/drc$ORACLE_SID.log

ls -l $ALERT_LOG
ls -l $DG_LOG

tail -f $ALERT_LOG &
tail -f $DG_LOG &

