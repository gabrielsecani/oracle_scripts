#!/bin/csh

setenv ORACLE_SID EP0
setenv ORACLE_VERSION 122
setenv ORACLE_BASE /oracle/$ORACLE_SID/$ORACLE_VERSION
setenv ORACLE_HOME $ORACLE_BASE/rdbms
setenv ORACLE_BIN $ORACLE_HOME/bin

if (! $?PATH_ORIGINAL ) then
  setenv PATH_ORIGINAL $PATH
endif

setenv PATH $PATH_ORIGINAL":$ORACLE_BIN"

echo ""
echo $ORACLE_HOME;
echo $ORACLE_BIN;
echo $ORACLE_SID;
echo $PATH;

alias sp "$ORACLE_BIN/sqlplus / as sysdba"
alias dg "dgmgrl /"
alias cdoh "cd $ORACLE_HOME"
alias cdon "cd $ORACLE_HOME/network/admin"
alias cdt "cd /oracle/EP0/saptrace/diag/rdbms/ep0b/EP0/trace"

alias sp0 "sqlplus SYS/DRSAP01EP0@EP0 as sysdba"
alias spa "sqlplus SYS/DRSAP01EP0@EP0A as sysdba"
alias spb "sqlplus SYS/DRSAP01EP0@EP0B as sysdba"

alias vitns "vi /oracle/EP0/11204/network/admin/tnsnames.ora"
alias vilsn "vi /oracle/EP0/11204/network/admin/listener.ora"

setprompt

