set serveroutput on feedback off

select db_unique_name from V$database;

begin
    for ct in (select status, filename from v$block_change_tracking)
    loop
        dbms_output.put_line('Block change tracking is actually ' || ct.status || '.' ||
            case when (ct.status='ENABLED') then chr(13)||' Change tracking file: '||ct.filename||'.' end);
        if (ct.filename like '+DATA%') then
            dbms_output.put_line('Change tracking file is wrong: '||ct.filename||'. ');
            execute immediate 'alter database disable block change tracking';
        end if;
        if (ct.status <> 'ENABLED' or ct.filename like '+DATA%') then
            dbms_output.put_line('Fixing block change tracking');
            execute immediate 'alter database enable block change tracking using file ''+ARCH''';
            for cts in (select status, filename from v$block_change_tracking)
            loop
              dbms_output.put_line('Block change tracking is now '||cts.status||'.');
              dbms_output.put_line(' Change tracking file: '||cts.filename||'.');
            end loop;
        end if;
    end loop;
end;
/

set feedback on
