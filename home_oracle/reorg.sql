WHENEVER SQLERROR EXIT SQL.SQLCODE
connect / as sysdba
set feedback off
spool reorg.log
set serverout on
set termout on

/*----------------------------------------------------------------------------------*/
/*  This script will gather all indexes on database with owner SAPSR3               */
/*                                                                                  */
/*  usage:                                                                          */
/*   UNIX: sqlplus /NOLOG @reorg.sql <rebuildParallel> <cont>                       */
/*                                                                                  */
/*  <rebuildParallel> - number of parallel to use for rebuild index                 */
/*       * Do not pass CPU count number *                                           */
/*  <cont> - if you need to continue the execution add 'cont' to parameters         */
/*                                                                                  */
/*----------------------------------------------------------------------------------*/

begin
  dbms_output.put_line('.  rebuildParallel:  &&1');
end;
/


declare
  c number;
begin

  delete reorg where lower('&&2') <> 'cont';
 
  insert into REORG (OWNER, TABLE_NAME, ROW_MOVEMENT, NUM_ROWS, INDEX_NAME)
  select TA.OWNER,TA.TABLE_NAME, TA.ROW_MOVEMENT, TA.NUM_ROWS, IX.INDEX_NAME
   from DBA_TABLES TA
   left join DBA_INDEXES IX on IX.TABLE_OWNER=TA.OWNER and IX.TABLE_NAME=TA.TABLE_NAME and IX.INDEX_TYPE!='LOB'
  where TA.OWNER in ('SAPSR3')
    and lower('&&2') <> 'cont'
  order by TA.NUM_ROWS;

  commit;
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


spool off

exit success

