rm nohup.out dup.log

nohup rman TARGET SYS/DRSAP01ED0@ED0B AUXILIARY SYS/DRSAP01ED0@ED0A @backup_rstr.rman log=dup.log

cat dup.log | mail -s "RAIA - Duplicate" gabrielltr84@gmail.com 
