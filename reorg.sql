WHENEVER SQLERROR EXIT SQL.SQLCODE
connect / as sysdba
set feedback off
spool oradbusr.log
set serverout on
set termout on

/*----------------------------------------------------------------------------------*/
/*  This script will gather all indexes on database with owner SAPSR3               */
/*                                                                                  */
/*  usage:                                                                          */
/*   UNIX: sqlplus /NOLOG @reorg.sql <rebuildParallel>                              */
/*                                                                                  */
/*  <rebuildParallel> - number of parallel to use for rebuild index                 */
/*       * Do not pass CPU count number *                                           */
/*                                                                                  */
/*----------------------------------------------------------------------------------*/

begin
  dbms_output.put_line('.  rebuildParallel:  &&1');
end;
/

set termout on

begin
  execute immediate 'drop table REORG';
exception when others then
  null;
end;
/

create table REORG(
  OWNER varchar2(100),
  TABLE_NAME varchar2(100),
  ROW_MOVEMENT varchar2(20),
  NUM_ROWS number(10),
  INDEX_NAME varchar2(100),
  MSG varchar2(4000),
  DATA_CONCLUSAO timestamp,
  DATA_ERRO timestamp
);

declare
  c number;
begin

insert into REORG (OWNER, TABLE_NAME, ROW_MOVEMENT, NUM_ROWS, INDEX_NAME, MSG)
  select TA.OWNER,TA.TABLE_NAME, TA.ROW_MOVEMENT, TA.NUM_ROWS, IX.INDEX_NAME, '--'
   from DBA_TABLES TA
   left join DBA_INDEXES IX on IX.TABLE_OWNER=TA.OWNER and IX.TABLE_NAME=TA.TABLE_NAME and IX.INDEX_TYPE!='LOB'
  where TA.OWNER in ('SAPSR3')
  --and rownum<=2000
  order by TA.NUM_ROWS;

  select count(*) into c from reorg;
  dbms_output.put_line('. ' || c ||' indexes to rebuild');

end;
/

declare 
  tb varchar2(30):='';
begin
  for tt in (select * from reorg where DATA_CONCLUSAO is null order by num_rows desc)
  LOOP
    begin
    if (TT.ROW_MOVEMENT='DISABLED') and (TB != TT.OWNER||'.'||TT.TABLE_NAME) then
      tb:=TT.OWNER||'."'||TT.TABLE_NAME||'"';
      execute immediate 'alter table '||TB||' enable row movement';
      execute immediate 'ALTER TABLE '||TB||' SHRINK SPACE CASCADE';
      execute immediate 'alter table '||TB||' disable row movement';
    end if;
    
    if (TT.INDEX_NAME is not null) then
      execute immediate 'alter index '||TT.OWNER||'."'||TT.INDEX_NAME||'" rebuild parallel &&1';
      execute immediate 'alter index '||TT.OWNER||'."'||TT.INDEX_NAME||'" parallel 1';
    end if;
    
    update REORG R set DATA_CONCLUSAO=systimestamp, MSG='OK'
     where R.OWNER=TT.OWNER
       and R.TABLE_NAME=TT.TABLE_NAME
       and R.INDEX_NAME=TT.INDEX_NAME;

    EXCEPTION 
    when OTHERS then
      declare SQLMSG varchar2(4000);
      begin
        sqlmsg := substr(sqlerrm, 1, 4000);
        update REORG R
           set DATA_ERRO=systimestamp, MSG=sqlmsg
         where R.OWNER=TT.OWNER
           and R.TABLE_NAME=TT.TABLE_NAME
           and R.INDEX_NAME=TT.INDEX_NAME;    
      end;
    end;
  end loop;
end;
/

exit success

alter system kill session 'sid, serial' immediate ;
alter system kill session '274, 39' immediate ;

----
set linesize 700
column MSG format a80
column pct_count format 9,990.9999
column pct_rows format 9,990.9999

select COUNT(*), MSG, sum(NUM_ROWS) as num_rows, round((sum(num_rows)/(select sum(num_rows) from REORG))*100,3) pct_rows
from REORG
--where msg='OK'
group by MSG
order by MSG;

compute sum of num_rows on report
compute sum of pct_count on report
compute sum of pct_rows on report
compute sum of qtde on report
break on report 
with t as (select sum(num_rows) num_rowst, count(*) countt from REORG)
select COUNT(*) qtde, MSG, sum(NUM_ROWS) as num_rows, 
	round((count(*)/t.countt)*100,4) pct_count,
	round((sum(num_rows)/t.num_rowst)*100,4) pct_rows
from REORG, t
--where msg='OK'
group by MSG, t.countt, t.num_rowst
order by num_rows asc;


select * from REORG 
order by NUM_ROWS desc, DATA_CONCLUSAO desc;

select count(*) from reorg where msg is null
order by NUM_ROWS desc, DATA_CONCLUSAO desc;
