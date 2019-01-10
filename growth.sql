-- origin[http://snapshottooold.blogspot.com.br/2017/02/oracle-tablespace-growth.html?m=0]
-- Tablespace growth perday over last 30 days
-- Note: Query will run only if diagnostic pack license is available
-- This query is a basic query and can be further tunned to improve performance

SELECT part.tsname tablespace_name,
       max(part.used_size) "Current Size (GB)",  /* Current size of tablespace */
       max(part.MAX_SIZE)-max(part.used_size) "Free (GB)",
       max(part.MAX_SIZE) "Max Size (GB)",  /* Current size of tablespace */
       Round(Avg(inc_used_size), 2) "Growth Per Day(GB)" /* Growth of tablespace per day */
 FROM 
 (SELECT sub.days,
         sub.tsname,
         used_size,MAX_SIZE,
         used_size - Lag (used_size, 1)
          over (PARTITION BY sub.tsname ORDER BY sub.tsname, sub.days) inc_used_size /* getting delta increase using analytic function */
       FROM  
       (SELECT TO_CHAR(hsp.begin_interval_time,'MM-DD-YYYY') days,
        hs.tsname,
		MAX((HU.TABLESPACE_MAXSIZE* dt.block_size )/(1024*1024*1024)) MAX_SIZE,
        MAX((hu.tablespace_usedsize* dt.block_size )/(1024*1024*1024)) used_size
      from
        dba_hist_tbspc_space_usage hu, /* historical tablespace usage statistics */
        dba_hist_tablespace_stat hs , /* tablespace information from the control file */
        dba_hist_snapshot hsp, /* information about the snapshots in the Workload Repository */
        dba_tablespaces dt
      where
        hu.snap_id = hsp.snap_id
        and hu.TABLESPACE_ID = hs.ts#
        and hs.tsname = dt.tablespace_name
        AND hsp.begin_interval_time > SYSDATE - 30 /* gathering info about last 30 days */
      GROUP  BY To_char(hsp.begin_interval_time, 'MM-DD-YYYY'),
        hs.tsname
      order by  hs.tsname,days) sub) part
GROUP  BY part.tsname
ORDER  BY part.tsname; 


-- Redo Log Switchs
COL C1 FORMAT A10 HEADING "MONTH"
COL C2 FORMAT A25 HEADING "ARCHIVE DATE"
COL C3 FORMAT 999 HEADING "SWITCHES"
COMPUTE AVG OF C ON A
COMPUTE AVG OF C ON REPORT
BREAK ON A SKIP 1 ON REPORT SKIP 1
SELECT TO_CHAR(TRUNC(FIRST_TIME), 'MONTH') C1, TO_CHAR(TRUNC(FIRST_TIME), 'DAY : DD-MON-YYYY') C2, COUNT(*) C3
  FROM V$LOG_HISTORY
  WHERE TRUNC(FIRST_TIME) > LAST_DAY(SYSDATE-100) +1
  GROUP BY TRUNC(FIRST_TIME)
  ORDER BY TRUNC(FIRST_TIME);


-- Daily Count and Size of Redo Log Space (Single Instance)
COL DAY FOR A12
BREAK ON REPORT
COMPUTE SUM LABEL "Total:" OF DAILY_AVG_GB ON REPORT
SELECT A.*, ROUND(A.COUNT#*B.AVG#/1024/1024/1024) DAILY_AVG_GB
  FROM (SELECT TO_CHAR(FIRST_TIME,'YYYY-MM-DD') DAY, COUNT(1) COUNT#, MIN(RECID) MIN#, MAX(RECID) MAX#
          FROM V$LOG_HISTORY
          WHERE first_time >sysdate-7
          GROUP BY TO_CHAR(FIRST_TIME,'YYYY-MM-DD')) A,
       (SELECT AVG(BYTES) AVG#, COUNT(1) COUNT#, MAX(BYTES) MAX_BYTES, MIN(BYTES) MIN_BYTES
          FROM V$LOG) B
ORDER BY DAY ASC;

-- Hourly count per day
set lines 400
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
----

COL "day" FOR A17
COL "d_0" FOR  A4
COL "d_1" FOR  A4
COL "d_2" FOR  A4
COL "d_3" FOR  A4
COL "d_4" FOR  A4
COL "d_5" FOR  A4
COL "d_6" FOR  A4
COL "d_7" FOR  A4
COL "d_8" FOR  A4
COL "d_9" FOR  A4
COL "d_10" FOR A4
COL "d_11" FOR A4
COL "d_12" FOR A4
COL "d_13" FOR A4
COL "d_14" FOR A4
COL "d_15" FOR A4
COL "d_16" FOR A4
COL "d_17" FOR A4
COL "d_18" FOR A4
COL "d_19" FOR A4
COL "d_20" FOR A4
COL "d_21" FOR A4
COL "d_22" FOR A4
COL "d_23" FOR A4
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


COL "day" FOR A17
COL "d_0" FOR  A4
COL "d_1" FOR  A4
COL "d_2" FOR  A4
COL "d_3" FOR  A4
COL "d_4" FOR  A4
COL "d_5" FOR  A4
COL "d_6" FOR  A4
COL "d_7" FOR  A4
COL "d_8" FOR  A4
COL "d_9" FOR  A4
COL "d_10" FOR A4
COL "d_11" FOR A4
COL "d_12" FOR A4
COL "d_13" FOR A4
COL "d_14" FOR A4
COL "d_15" FOR A4
COL "d_16" FOR A4
COL "d_17" FOR A4
COL "d_18" FOR A4
COL "d_19" FOR A4
COL "d_20" FOR A4
COL "d_21" FOR A4
COL "d_22" FOR A4
COL "d_23" FOR A4
col g1 for 99.00
col g2 for 99.00
col g3 for 99.00
col g4 for 99.00
select day
	,g1/total*100 as g1
	,g2/total*100 as g2
	,g3/total*100 as g3
	,g4/total*100 as g4
from (
select day, 
	d_22+d_23+d_21+ 
	d_0+d_1+d_2+d_3+d_4+d_5+d_6+d_7+d_8+d_9 as g1,
	d_10+d_11+d_12+d_13+d_14+d_15 as g2,
	d_16+d_17+d_18+d_19+d_20 as g3,
	0 as g4, Total
	from (
select to_char(FIRST_TIME,'DY, DD-MON-YYYY') day,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0))) d_0,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0))) d_1,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0))) d_2,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0))) d_3,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0))) d_4,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0))) d_5,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0))) d_6,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0))) d_7,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0))) d_8,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0))) d_9,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0))) d_10,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0))) d_11,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0))) d_12,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0))) d_13,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0))) d_14,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0))) d_15,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0))) d_16,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0))) d_17,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0))) d_18,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0))) d_19,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0))) d_20,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0))) d_21,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0))) d_22,
       to_number(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0))) d_23,
       to_number(count(trunc(FIRST_TIME))) Total
  from v$log_history
 group by to_char(FIRST_TIME,'DY, DD-MON-YYYY')
 order by to_date(substr(to_char(FIRST_TIME,'DY, DD-MON-YYYY'),5,15) )
)
)
/
