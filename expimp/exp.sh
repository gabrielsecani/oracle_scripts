expdp exportcast/DRSAP01EP0 \
  JOB_NAME=EXPORT_SAPSR3 DIRECTORY=EXPOMIGRACAO \
  DUMPFILE=drsapsr3_%U.dmp LOGFILE=drsapr3_export.log filesize=16G\
  FULL=N SCHEMAS=SAPSR3 \
  PARALLEL=12

cd ..
gzip -c drsapr3_export.log > drsapr3_export.log.gz
echo "Export SAP OLD PROD has finished" | mutt -a drsapr3_export.log.gz -s "[RAIA] Export OLD PROD" gabriel.ribeiro@castgroup.com.br
echo "Export SAP OLD PROD has finished" | mutt -a drsapr3_export.log.gz -s "[RAIA] Export OLD PROD" gabrielltr84@gmail.com

