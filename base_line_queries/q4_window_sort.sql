ALTER SESSION SET USE_CACHED_RESULT = FALSE;
-- Clear the warehouse disk cache between tests:
ALTER WAREHOUSE wh_xs SUSPEND;
ALTER WAREHOUSE wh_xs RESUME;
ALTER SESSION SET QUERY_TAG = 'query_base_4';


SELECT l_suppkey, l_orderkey, l_extendedprice,
ROW_NUMBER() OVER (PARTITION BY l_suppkey ORDER BY l_extendedprice
DESC) AS rn
FROM line_item_raw
QUALIFY rn <= 3;

insert into  baseq_runtimes 
SELECT query_tag, query_text,query_id, warehouse_size,
total_elapsed_time / 1000 AS seconds,
bytes_scanned, query_acceleration_bytes_scanned, query_acceleration_partitions_scanned,
bytes_written_to_result, rows_written_to_result,
 query_retry_time
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY(RESULT_LIMIT => 100))
WHERE query_tag ='query_base_4' AND query_tag <> '' and query_text like 'SELECT l_suppkey, l_orderkey%' and execution_status ='SUCCESS'
ORDER BY start_time DESC;


SELECT table_name, start_time, credits_used, num_bytes_reclustered
FROM snowflake.account_usage.automatic_clustering_history
ORDER BY start_time DESC LIMIT 20;