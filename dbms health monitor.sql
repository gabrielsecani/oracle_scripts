--https://www.morganslibrary.org/reference/pkgs/dbms_hm.html
exec dbms_hm.drop_schema(TRUE);
exec dbms_hm.create_schema;

col check_name format a30
col parameter_name format a18
col type format a15
col default_value format a15
col description format a40

SELECT c.name check_name, p.name parameter_name, p.type,
p.default_value, p.description
FROM v$hm_check_param p, v$hm_check c
WHERE p.check_id = c.id and c.internal_check = 'N'
ORDER BY c.name;


-- * Checkers
ASM Allocation Check
CF Block Integrity Check
DB Structure Integrity Check
Data Block Integrity Check
Dictionary Integrity Check
Redo Integrity Check
Transaction Integrity Check
Undo Segment Integrity Check

SELECT * FROM gv$hm_check;
SELECT run_id FROM gv$hm_run;

exec dbms_hm.run_check('Dictionary Integrity Check','Run 1', 60);
exec dbms_hm.run_check('ASM Allocation Check', 'Run ASM', 60);
exec dbms_hm.run_check('DB Structure Integrity Check', 'Run ', 60);
exec dbms_hm.run_check('Data Block Integrity Check', 'Run ', 60);
exec dbms_hm.run_check('Dictionary Integrity Check', 'Run ', 60);
exec dbms_hm.run_check('Redo Integrity Check', 'Run ', 60);
exec dbms_hm.run_check('Transaction Integrity Check', 'Run ', 60);
exec dbms_hm.run_check('Undo Segment Integrity Check', 'Run Undo', 60);

dbms_hm.run_check(check_name IN VARCHAR2,
checkname    IN VARCHAR2,
run_name     IN VARCHAR2 := NULL,
timeout      IN NUMBER   := NULL,
input_params IN VARCHAR2 := NULL);


col name format a12
SELECT run_id, name, check_name, run_mode, status, src_incident, num_incident, error_number
FROM gv$hm_run
ORDER  BY 1;
col name format a12
SELECT run_id, name, check_name, run_mode, status, src_incident, num_incident, error_number
FROM gv$hm_run
ORDER  BY 1;

col description format a40
col damage_description format a40
SELECT finding_id, status, type, description, damage_description
FROM gv$hm_finding
WHERE run_id = 1;

col name format a10
col repair_script format a60

SELECT name, type, rank, status, repair_script
FROM gv_$hm_recommendation
WHERE run_id = 1
AND fdg_id = 22;


