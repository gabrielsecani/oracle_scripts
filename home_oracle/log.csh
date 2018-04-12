#!/bin/csh
set T="/oracle/EP0/saptrace/diag/rdbms/ep0b/EP0/trace"

tail -f -500 $T/alert_EP0.log&
tail -f -400 $T/drcEP0.log&


