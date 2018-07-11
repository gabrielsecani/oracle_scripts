setenv ORACLE_BASE /oracle/EQ0/122
setenv ORACLE_HOME $ORACLE_BASE/rdbms
setenv ORACLE_SID EQ0
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
alias dg "dgmgrl SYS/DRSAP01EQ0"
alias cdoh "cd $ORACLE_HOME"
alias cdon "cd $ORACLE_HOME/network/admin"

alias sp0 "sqlplus SYS/DRSAP01EQ0@EQ0 as sysdba"
alias spa "sqlplus SYS/DRSAP01EQ0@EQ0A as sysdba"
alias spb "sqlplus SYS/DRSAP01EQ0@EQ0B as sysdba"

alias vitns "vi $ORACLE_HOME/network/admin/tnsnames.ora"
alias vilsn "vi $ORACLE_HOME/network/admin/listener.ora"

alias bk "/backup/bk.sh"

setprompt

