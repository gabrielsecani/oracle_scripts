setenv ORACLE_BASE /oracle/EP0/122
setenv ORACLE_HOME $ORACLE_BASE/grid
setenv ORACLE_SID +ASM
setenv ORACLE_BIN $ORACLE_HOME/bin
setenv LD_LIBRARY_PATH $ORACLE_HOME/lib

if (! $?PATH_ORIGINAL ) then
  setenv PATH_ORIGINAL $PATH
endif

setenv OPATCH "$ORACLE_HOME/OPatch"
setenv PATH $PATH_ORIGINAL":${ORACLE_BIN}":"${OPATCH}"

echo ""
echo $ORACLE_HOME;
echo $ORACLE_BIN;
echo $ORACLE_SID;
echo $PATH;

alias sp "$ORACLE_BIN/sqlplus / as sysasm"
alias asmcmd "asmcmd -p"
alias cdoh "cd $ORACLE_HOME"
alias cdon "cd $ORACLE_HOME/network/admin"

setprompt
