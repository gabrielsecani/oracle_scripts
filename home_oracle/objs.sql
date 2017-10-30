
select object_type, null "bytes|(GB)", count(*) "QTDE" from dba_objects where owner='SAPSR3' group by object_type
union
select 'Segments Size' object_type, sum(bytes)/1024/1024/1024, count(*) from dba_segments where owner='SAPSR3'
/

select 
 ((select count(*) "QTDE" from dba_objects where owner='SAPSR3') + 
 (select sum(bytes)/1024/1024/1024 from dba_segments where owner='SAPSR3') ) / 185198 * 100 as PCTCONCLUIDO
from dual
/


