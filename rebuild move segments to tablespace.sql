-- https://eduardolegatti.blogspot.com/2014/01/movendo-tabelas-indices-e-segmentos-lob.html

set timing on

SELECT 'alter table "' 
		|| t.owner
		|| '"."'
		|| t.table_name 
		|| '" move lob ('
		|| column_name   
		|| ') store as (tablespace PSAPSR3_LOB);' CMD   
	FROM dba_lobs l, dba_tables t   
	WHERE l.owner = t.owner  
		AND l.table_name = t.table_name 
		AND l.SEGMENT_NAME IN  
			(SELECT segment_name  
				FROM dba_segments  
				WHERE segment_type = 'LOBSEGMENT'  
				AND OWNER = 'SAPSR3'  
				AND tablespace_name = 'PSAPSR3DB')
		AND l.owner = 'SAPSR3'  
	ORDER BY t.owner, t.table_name;

SELECT 'alter table "' 
		|| t.owner
		|| '"."'
		|| t.table_name 
		|| '" move lob ('
		|| column_name
		|| ') store as (tablespace PSAPSR3_LOB);' CMD   
	FROM dba_lobs l, dba_tables t   
	WHERE l.owner = t.owner  
		AND l.table_name = t.table_name 
		AND l.SEGMENT_NAME like 
		'SYS_LOB0000425634C00038$$'
	ORDER BY t.owner, t.table_name;

SELECT ' alter index "'
		|| owner   
		|| '"."'  
		|| index_name
		|| '" rebuild ONLINE COMPUTE STATISTICS;' CMD
	FROM dba_indexes   
	WHERE index_type <> 'LOB' AND owner = 'SAPSR3DB';

select OWNER,INDEX_NAME,INDEX_TYPE,TABLE_OWNER,TABLE_NAME,TABLE_TYPE,STATUS
	FROM dba_indexes   
	WHERE TABLE_NAME = 'BC_MSG';
	
 SELECT ui.owner, ui.index_name
    , ui.table_name
    , ui.index_type
    , ui.global_stats
    , to_char(ui.last_analyzed, 'DD/MM/YYYY HH24:Mi') last_analyzed
    FROM DBA_INDEXES ui
    WHERE ui.last_analyzed < add_months(sysdate, -6)
    and ui.owner = 'SAPSR3'
    and ui.PARTITIONED = 'NO'


