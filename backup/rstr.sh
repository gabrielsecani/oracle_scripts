rm nohup.out dup.log

nohup rman TARGET SYS/DRSAP01EQ0@EQ0A AUXILIARY SYS/DRSAP01EQ0@EQ0B @backup_rstr.rman log=dup.log

cat dup.log | mail -s "RAIA - Duplicate" gabrielltr84@gmail.com &

