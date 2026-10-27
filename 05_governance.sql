USE ROLE ACCOUNTADMIN;
CREATE OR REPLACE MASKING POLICY perf_lab.tpch.mask_acctbal
AS (val NUMBER(12,2)) RETURNS NUMBER(12,2) ->
CASE WHEN CURRENT_ROLE() IN ('ENGINEER_ROLE', 'ACCOUNTADMIN') THEN val ELSE NULL END;

ALTER TABLE perf_lab.tpch.customer
MODIFY COLUMN c_acctbal SET MASKING POLICY perf_lab.tpch.mask_acctbal;

-- 2. Object tag to classify sensitive data
CREATE OR REPLACE TAG perf_lab.tpch.sensitivity;
ALTER TABLE perf_lab.tpch.customer
MODIFY COLUMN c_acctbal SET TAG perf_lab.tpch.sensitivity = 'confidential';



USE ROLE engineer_role; 
USE WAREHOUSE wh_xs;
SELECT c_custkey, c_acctbal FROM perf_lab.tpch.customer LIMIT 5; -- values








USE ROLE analyst_role; 
USE WAREHOUSE wh_xs;
SELECT c_custkey, c_acctbal FROM perf_lab.tpch.customer LIMIT 5; 









-- 4. Who accessed what (Enterprise edition, delayed up to about 3 hours)
USE ROLE ACCOUNTADMIN;
SELECT query_start_time, user_name, direct_objects_accessed
FROM snowflake.account_usage.access_history
ORDER BY query_start_time DESC LIMIT 20;




