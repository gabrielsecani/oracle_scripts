SPOOL features.txt
set lines 300
show parameter db_unique_name
select      name, 
            version, 
            detected_usages, 
            currently_used, 
            first_usage_date, 
            last_usage_date, 
            description
from        DBA_FEATURE_USAGE_STATISTICS  
where       detected_usages > 0 
order by    name, version;

SELECT  PARAMETER C1,
        VALUE     C2
 FROM   X$OPTION;

spool off
