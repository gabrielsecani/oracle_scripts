clear screen
set serveroutput on 

select db_unique_name from V$database;

begin
    for s in (select SEGMENT_TYPE, OWNER, SEGMENT_NAME from dba_segments where tablespace_name='PSAPSR3701' order by 1)
    loop
        --dbms_output.put_line('Segmento '||s.segment_name||', tipo: '||s.segment_type);
        if s.SEGMENT_TYPE = 'INDEX' then
            dbms_output.put_line('alter index '||s.OWNER||'.'||s.SEGMENT_NAME||' rebuild tablespace PSAPSR3750;');
        end if;
        if s.SEGMENT_TYPE = 'TABLE' then
            dbms_output.put_line('alter table '||s.OWNER||'.'||s.SEGMENT_NAME||' move tablespace PSAPSR3750;');        
        end if;
    end loop;
end;
/


set serveroutput on feedback off
spool rebuilding_indexes.sql

prompt spool rebuilding_indexes.log

prompt prompt PARTITION INDEXES
begin for cs in (
    SELECT ui.owner, uip.index_name
    , utp.table_name
    , uip.partition_name
    , ui.index_type
    , ui.global_stats
    , to_char(uip.last_analyzed, 'DD/MM/YYYY HH24:Mi') last_analyzed
    FROM DBA_IND_PARTITIONS uip, DBA_TAB_PARTITIONS utp, DBA_INDEXES ui
    WHERE uip.partition_name= utp.partition_name
    AND ui.index_name=uip.index_name
    AND ui.table_name = utp.table_name
    and uip.last_analyzed < add_months(sysdate,-1)
    and ui.owner = 'SAPSR3'
    and ui.PARTITIONED = 'YES'
    --and UI.status <> 'VALID'
    and rownum <= 50
) loop
    dbms_output.put_line('alter index ' || cs.owner || '."' || cs.index_name || '" rebuild partition '||cs.partition_name||' ONLINE COMPUTE STATISTICS;');
end loop;
end;
/

prompt prompt INDEXES
begin for cs in (
    SELECT ui.owner, ui.index_name
    , ui.table_name
    , ui.index_type
    , ui.global_stats
    , to_char(ui.last_analyzed, 'DD/MM/YYYY HH24:Mi') last_analyzed
    FROM DBA_INDEXES ui
    WHERE ui.last_analyzed < add_months(sysdate, -6)
    and ui.owner = 'SAPSR3'
    and ui.PARTITIONED = 'NO'
    and rownum <= 50
) loop
    dbms_output.put_line('alter index ' || cs.owner || '."' || cs.index_name || '" rebuild ONLINE COMPUTE STATISTICS;');
end loop;
end;
/

prompt spool off
spool off

set feedback on

@rebuilding_indexes.sql
