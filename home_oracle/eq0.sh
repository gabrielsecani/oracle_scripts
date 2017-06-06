setenv ORACLE_HOME /oracle/EQ0/11204
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

set prompt="$ORACLE_SID % "

alias sp "$ORACLE_BIN/sqlplus / as sysdba"
alias dg "dgmgrl SYS/drSAP01EQ0"
alias cdoh "cd $ORACLE_HOME"
alias cdon "cd $ORACLE_HOME/network/admin"

alias sp0 "sqlplus SYS/drSAP01EQ0@EQ0 as sysdba"
alias spa "sqlplus SYS/drSAP01EQ0@EQ0A as sysdba"
alias spb "sqlplus SYS/drSAP01EQ0@EQ0B as sysdba"


