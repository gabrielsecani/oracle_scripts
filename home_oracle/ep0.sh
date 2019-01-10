#!/bin/csh

setenv ORACLE_SID EP0
setenv ORACLE_VERSION 122
setenv ORACLE_BASE /oracle/$ORACLE_SID/$ORACLE_VERSION
setenv ORACLE_HOME $ORACLE_BASE/rdbms
setenv ORACLE_BIN $ORACLE_HOME/bin

if (! $?PATH_ORIGINAL ) then
  setenv PATH_ORIGINAL $PATH
endif

setenv OPATCH "$ORACLE_HOME/OPatch"
setenv PATH $PATH_ORIGINAL":$ORACLE_BIN"
setenv PATH $PATH":$ORACLE_HOME/OPatch"

setenv LD_LIBRARY_PATH $ORACLE_HOME/lib

echo ""
echo $ORACLE_HOME;
echo $ORACLE_BIN;
echo $ORACLE_SID;
echo $PATH;

setprompt

alias sp "$ORACLE_BIN/sqlplus / as sysdba"
alias dg "dgmgrl /"
alias cdoh "cd $ORACLE_HOME"
alias cdon "cd $ORACLE_HOME/network/admin"
alias cdt "cd /oracle/${ORACLE_SID}/saptrace/diag/rdbms/ed0b/ED0/trace"

alias sp0 "sqlplus SYS/DRSAP01$ORACLE_SID@"$ORACLE_SID" as sysdba"
alias spa "sqlplus SYS/DRSAP01$ORACLE_SID@"$ORACLE_SID"A as sysdba"
alias spb "sqlplus SYS/DRSAP01$ORACLE_SID@"$ORACLE_SID"B as sysdba"

alias vitns "vi $ORACLE_HOME/network/admin/tnsnames.ora"
alias vilsn "vi $ORACLE_HOME/network/admin/listener.ora"

alias bk "/backup/bk.sh"
