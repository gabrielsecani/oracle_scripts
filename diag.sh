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
LISTENER_LOG=$ORACLE_BASE/diag/tnslsnr/$(hostname -s)/listener/trace/listener.log
ALERT_LOG=$DIAG_DEST/alert_$ORACLE_SID.log
DG_LOG=$DIAG_DEST/drc$ORACLE_SID.log
ls -l $ALERT_LOG
ls -l $DG_LOG
ls -l $LISTENER_LOG

tail -f $ALERT_LOG&
tail -f $DG_LOG&
tail -f $LISTENER_LOG&

