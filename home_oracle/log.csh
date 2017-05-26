#!/bin/csh

tail -f -200 /oracle/ED0/saptrace/diag/rdbms/ed0b/EQ0/trace/alert_ED0.log&
tail -f -200 /oracle/ED0/saptrace/diag/rdbms/ed0b/EQ0/trace/drcED0.log&

tail -f -200 /oracle/EQ0/saptrace/diag/rdbms/eq0b/EQ0/trace/alert_EQ0.log&
tail -f -200 /oracle/EQ0/saptrace/diag/rdbms/eq0b/EQ0/trace/drcEQ0.log&

