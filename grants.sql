-- fazer backup privilegios   -- DONE
set head off
set line 180
col priv for a100

spool grants.log

select decode( GRANTABLE, 'YES',
                          'grant ' || privilege || ' on ' || owner || '.' || table_name || ' to ' || grantee || ' with grant option;',
                          'grant ' || privilege || ' on ' || owner || '.' || table_name || ' to ' || grantee || ' ;') priv
from dba_tab_privs
union
select decode( ADMIN_OPTION, 'YES',
                          'grant ' || privilege || ' to ' || grantee || ' with admin option;',
                          'grant ' || privilege || ' to ' || grantee || ' ;') priv
from dba_sys_privs
union
select decode( ADMIN_OPTION, 'YES',
                          'grant ' || GRANTED_ROLE || ' to ' || grantee || ' with admin option;',
                          'grant ' || GRANTED_ROLE || ' to ' || grantee || ' ;') priv
from dba_role_privs
/

spool off
set head on