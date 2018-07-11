
col sql_text for a60

select t.*, (select st.sql_text from dba_hist_sqltext st where t.sql_id=st.sql_id )  sql_text
from (
with t as (
    select session_id,session_serial#, SQL_EXEC_ID,sql_id
           , max(sample_time) - min(sample_time) as dur#
    from v$active_session_history where sql_id is not null and sql_exec_id is not null
    group by session_id,session_serial#, SQL_EXEC_ID, sql_id )
select count (*),nvl(sql_id,'TOTAL') SQL_ID,
       round(avg(extract( second from t.dur# )
          + extract( minute from t.dur# ) * 60
          + extract( hour   from t.dur# ) * 60 * 60
          + extract( day    from t.dur# ) * 60 * 60 * 24 ),3) avg_seconds ,
       round (sum (extract( second from t.dur# )
          + extract( minute from t.dur# ) * 60
          + extract( hour   from t.dur# ) * 60 * 60
          + extract( day    from t.dur# ) * 60 * 60 * 24 ),3) tot_seconds,
       round (100* ( round (sum (extract( second from t.dur# )
          + extract( minute from t.dur# ) * 60
          + extract( hour   from t.dur# ) * 60 * 60
          + extract( day    from t.dur# ) * 60 * 60 * 24 ),3) /  
            ( select sum (extract( second from t.dur# )
             + extract( minute from t.dur# ) * 60
             + extract( hour   from t.dur# ) * 60 * 60
             + extract( day    from t.dur# ) * 60 * 60 * 24 ) from t ) ),2) as pct
  from t
  group by rollup ( sql_id )
  order by 5 desc
) t
where rownum < 21;