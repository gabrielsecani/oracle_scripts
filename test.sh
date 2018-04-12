#/bin/csh

setenv ORACLE_SID EP0
setenv ORACLE_HOME /oracle/EP0/11204
setenv ORACLE_BIN /oracle/EP0/11204/bin
setenv PATH "$PATH;$ORACLE_BIN"

output=`sqlplus -s "/ as sysdba" <<EOF
select to_char(sysdate, ''dd/mm/yyyy hh24:mi:ss'') "AGORA" from dual;
@/home/oracle/status
@/home/oracle/tbspace
exit
EOF
`
echo $output

#echo $output | sed -e 's/[ /t]*$//' -e 's/^M//g' > status.log

echo $output > status.log

mailTO="gabriel.ribeiro@cast.com.br"

mail -s "[RAIA] - Monitoramento de Status `uname -a`" $mailTO < status.log

