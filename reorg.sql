set SERVEROUTPUT on

--drop table REORG;

create table REORG(
  OWNER varchar2(100),
  TABLE_NAME varchar2(100),
  ROW_MOVEMENT varchar2(20),
  NUM_ROWS number(10),
  INDEX_NAME varchar2(100),
  MSG varchar2(4000),
  DATA_CONCLUSAO timestamp,
  DATA_ERRO timestamp
  --, constraint pkreorg primary key(owner,table_name, index_name)
);


insert into REORG (OWNER, TABLE_NAME, ROW_MOVEMENT, NUM_ROWS, INDEX_NAME)
  select TA.OWNER,TA.TABLE_NAME, TA.ROW_MOVEMENT, TA.NUM_ROWS, IX.INDEX_NAME
   from DBA_TABLES TA
   left join DBA_INDEXES IX on IX.TABLE_OWNER=TA.OWNER and IX.TABLE_NAME=TA.TABLE_NAME and IX.INDEX_TYPE!='LOB'
  where TA.OWNER in ('SAPSR3')
  --and rownum<=2000
  order by TA.NUM_ROWS;

select count(*) from reorg;

declare 
  tb varchar2(30):='';
begin
  for tt in (select * from reorg where DATA_CONCLUSAO is null order by num_rows)
  LOOP
    begin
    if (TT.ROW_MOVEMENT='DISABLED') and (TB != TT.OWNER||'.'||TT.TABLE_NAME) then
      tb:=TT.OWNER||'."'||TT.TABLE_NAME||'"';
      execute immediate 'alter table '||TB||' enable row movement';
      execute immediate 'ALTER TABLE '||TB||' SHRINK SPACE CASCADE';
      execute immediate 'alter table '||TB||' disable row movement';
    end if;
    
    if (TT.INDEX_NAME is not null) then
      execute immediate 'alter index '||TT.OWNER||'."'||TT.INDEX_NAME||'" rebuild parallel 8';
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

select COUNT(*), MSG, sum(NUM_ROWS), round((sum(num_rows)/(select sum(num_rows) from REORG))*100,3) pct
from REORG
--where msg='OK'
group by MSG;

select * from REORG 
order by NUM_ROWS desc, DATA_CONCLUSAO desc;

select * from reorg where msg is null;