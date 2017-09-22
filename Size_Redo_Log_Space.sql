-- Daily Count and Size of Redo Log Space (Single Instance)
COL DAY FOR A12
BREAK ON REPORT
COMPUTE SUM LABEL "Total:" OF DAILY_AVG_GB ON REPORT
SELECT A.*, ROUND(A.COUNT#*B.AVG#/1024/1024/1024) DAILY_AVG_GB
  FROM (SELECT TO_CHAR(FIRST_TIME,'YYYY-MM-DD') DAY, COUNT(1) COUNT#, MIN(RECID) MIN#, MAX(RECID) MAX#
          FROM V$LOG_HISTORY
          WHERE first_time >sysdate-7
          GROUP BY TO_CHAR(FIRST_TIME,'YYYY-MM-DD')
          ORDER BY 1 DESC) A,
       (SELECT AVG(BYTES) AVG#, COUNT(1) COUNT#, MAX(BYTES) MAX_BYTES, MIN(BYTES) MIN_BYTES
          FROM V$LOG) B;

-- Hourly count per day
COL "00" FOR A5
COL "01" FOR A5
COL "02" FOR A5
COL "03" FOR A5
COL "04" FOR A5
COL "05" FOR A5
COL "06" FOR A5
COL "07" FOR A5
COL "08" FOR A5
COL "09" FOR A5
COL "10" FOR A5
COL "11" FOR A5
COL "12" FOR A5
COL "13" FOR A5
COL "14" FOR A5
COL "15" FOR A5
COL "16" FOR A5
COL "17" FOR A5
COL "18" FOR A5
COL "19" FOR A5
COL "20" FOR A5
COL "21" FOR A5
COL "22" FOR A5
COL "23" FOR A5
SELECT TO_CHAR(FIRST_TIME,'YYYY-MM-DD') DAY, TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'00',1,0)),'999') "00",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'01',1,0)),'999') "01", TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'02',1,0)),'999') "02",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'03',1,0)),'999') "03", TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'04',1,0)),'999') "04",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'05',1,0)),'999') "05", TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'06',1,0)),'999') "06",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'07',1,0)),'999') "07", TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'08',1,0)),'999') "08",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'09',1,0)),'999') "09", TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'10',1,0)),'999') "10",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'11',1,0)),'999') "11", TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'12',1,0)),'999') "12",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'13',1,0)),'999') "13", TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'14',1,0)),'999') "14",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'15',1,0)),'999') "15", TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'16',1,0)),'999') "16",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'17',1,0)),'999') "17", TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'18',1,0)),'999') "18",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'19',1,0)),'999') "19", TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'20',1,0)),'999') "20",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'21',1,0)),'999') "21", TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'22',1,0)),'999') "22",
       TO_CHAR(SUM(DECODE(TO_CHAR(FIRST_TIME,'HH24'),'23',1,0)),'999') "23"
  FROM V$LOG_HISTORY
  GROUP BY TO_CHAR(FIRST_TIME,'YYYY-MM-DD')
  ORDER BY 1;
OU
set lines 132
column day format a16  heading 'Day'
column d_0 format a3  heading '00'
column d_1 format a3  heading '01'
column d_2 format a3  heading '02'
column d_3 format a3  heading '03'
column d_4 format a3  heading '04'
column d_5 format a3  heading '05'
column d_6 format a3  heading '06'
column d_7 format a3  heading '07'
column d_8 format a3  heading '08'
column d_9 format a3  heading '09'
column d_10 format a3  heading '10'
column d_11 format a3  heading '11'
column d_12 format a3  heading '12'
column d_13 format a3  heading '13'
column d_14 format a3  heading '14'
column d_15 format a3  heading '15'
column d_16 format a3  heading '16'
column d_17 format a3  heading '17'
column d_18 format a3  heading '18'
column d_19 format a3  heading '19'
column d_20 format a3  heading '20'
column d_21 format a3  heading '21'
column d_22 format a3  heading '22'
column d_23 format a3  heading '23'
column  Total   format 9999
column status  format a8
column member  format a40
column archived heading "Archived" format a8
column bytes heading "Bytes|(MB)" format 9999
Ttitle  "Log Info"  skip 2
select l.group#,f.member,l.archived,l.bytes/1078576 bytes,l.status,f.type
  from v$log l, v$logfile f
 where l.group# = f.group#
/
Ttitle off
prompt =========================================================================================================================
Ttitle  "Log Switch on hour basis"  skip 2

select to_char(FIRST_TIME,'DY, DD-MON-YYYY') day,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0))) d_0,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0))) d_1,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0))) d_2,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0))) d_3,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0))) d_4,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0))) d_5,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0))) d_6,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0))) d_7,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0))) d_5,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0))) d_9,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0))) d_10,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0))) d_11,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0))) d_12,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0))) d_13,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0))) d_14,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0))) d_15,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0))) d_16,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0))) d_17,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0))) d_18,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0))) d_19,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0))) d_20,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0))) d_21,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0))) d_22,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0))) d_23,
       count(trunc(FIRST_TIME)) "Total"
  from v$log_history
 group by to_char(FIRST_TIME,'DY, DD-MON-YYYY')
 order by to_date(substr(to_char(FIRST_TIME,'DY, DD-MON-YYYY'),5,15) )
/
Ttitle off
prompt =========================================================================================================================
