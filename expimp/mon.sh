#/bin/csh
# /mnt_hades/dump/scripts/mon.sh
cd /mnt_hades/dump

date > /tmp/dump.log

echo DISK MOUNT >> /tmp/dump.log
df -g . >> /tmp/dump.log

echo DISK USAGE >> /tmp/dump.log
du -g . >> /tmp/dump.log


echo LAST 30 LOG LINES >> /tmp/dump.log
tail -30 drsapr3_export.log >> /tmp/dump.log

cat /tmp/dump.log | mail -s "[RAIA] Dump monitor" "gabriel.ribeiro@castgroup.com.br; gabrielltr84@gmail.com"

#
crontab -e << EOF
#-- Item Description
#-- minute      0 through 59
#-- hour        0 through 23
#-- day_of_month        1 through 31
#-- month       1 through 12
#-- weekday     0 through 6 for Sunday through Saturday: 0 domingo, 1 segunda,2 terca, 3 quarta, 4 quinta, 5 sexta, 6 sabado
#-- command     a shell command

0,20,40 * * * * /mnt_hades/dump/scripts/mon.sh >> /dev/null
EOF
