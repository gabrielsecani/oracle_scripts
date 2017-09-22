# RDBMS environment
# @(#) $Id: //bas/721_REL/src/krn/tpls/ind/DBSRC.CSH#1 $ SAP
if ( -e $HOME/.dbenv_`hostname`.csh ) then
   source $HOME/.dbenv_`hostname`.csh
else if ( -e $HOME/.dbenv.csh ) then
   source $HOME/.dbenv.csh
endif

alias ls "ls -a"
alias ll "ls -ltra"

set hostname=`uname -n`
if (! $?ORACLE_SID ) then
  setenv ORACLE_SID ""
endif
alias setprompt 'set prompt="${hostname}:${ORACLE_SID}:${cwd} \! % "'
alias cd 'chdir \!* && setprompt'
setprompt

