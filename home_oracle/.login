#!/bin/csh
set path = ( /usr/bin /etc /usr/sbin /usr/ucb $HOME/bin /usr/bin/X11 /sbin . )
setenv MAIL "/var/spool/mail/$LOGNAME"
setenv MAILMSG "[YOU HAVE NEW MAIL]"
if ( -f "$MAIL" && ! -z "$MAIL") then
        echo "$MAILMSG"
endif

echo "######## asm"
alias asm "source ~/asm.sh"

echo "######## ep0"
alias ep0 "source ~/ep0.sh"

alias dg "dgmgrl SYS/DRSAP01EP0"

