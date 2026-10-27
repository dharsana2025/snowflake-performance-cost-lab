ALTER SESSION SET USE_CACHED_RESULT = FALSE;
-- Clear the warehouse disk cache between tests:
ALTER WAREHOUSE wh_xs SUSPEND;
ALTER WAREHOUSE wh_xs RESUME;
ALTER SESSION SET QUERY_TAG = 'query_base_2';


SELECT l_returnflag, l_linestatus,
SUM(l_quantity) AS sum_qty,
SUM(l_extendedprice) AS sum_price
FROM line_item_raw
WHERE YEAR(l_shipdate) = 1995 AND MONTH(l_shipdate) <= 3
GROUP BY l_returnflag, l_linestatus;

insert into baseq_runtimes   
SELECT query_tag, query_text,query_id, warehouse_size,
total_elapsed_time / 1000 AS seconds,
bytes_scanned, query_acceleration_bytes_scanned, query_acceleration_partitions_scanned,
bytes_written_to_result, rows_written_to_result,
 query_retry_time
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY(RESULT_LIMIT => 100))
WHERE query_tag ='query_base_2' AND query_tag <> '' and query_text like 'SELECT l_returnflag,%' and execution_status ='SUCCESS'
ORDER BY start_time DESC;

select * from baseq_runtimes ; 

delete from baseq_runtimes  where  query_tag ='clustered_q1';

SELECT * FROM snowflake.account_usage.automatic_clustering_history
ORDER BY start_time DESC LIMIT 20;




ALTER SESSION SET USE_CACHED_RESULT = FALSE;
-- Clear the warehouse disk cache between tests:
ALTER WAREHOUSE wh_xs SUSPEND;
ALTER WAREHOUSE wh_xs RESUME;
ALTER SESSION SET QUERY_TAG = 'query_base2_wyr';


SELECT l_returnflag, l_linestatus,
SUM(l_quantity) AS sum_qty,
SUM(l_extendedprice) AS sum_price
FROM line_item_raw
WHERE YEAR(l_shipdate) between 1992 and 1998 AND MONTH(l_shipdate) between 1 and 12
GROUP BY l_returnflag, l_linestatus;

insert into baseq_runtimes   
SELECT query_tag, query_text,query_id, warehouse_size,
total_elapsed_time / 1000 AS seconds,
bytes_scanned, query_acceleration_bytes_scanned, query_acceleration_partitions_scanned,
bytes_written_to_result, rows_written_to_result,
 query_retry_time
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY(RESULT_LIMIT => 100))
WHERE query_tag ='query_base2_wyr' AND query_tag <> '' and query_text like 'SELECT l_returnflag,%' and execution_status ='SUCCESS'
ORDER BY start_time DESC;




ALTER SESSION SET USE_CACHED_RESULT = FALSE;
-- Clear the warehouse disk cache between tests:
ALTER WAREHOUSE wh_xs SUSPEND;
ALTER WAREHOUSE wh_xs RESUME;
ALTER SESSION SET QUERY_TAG = 'clustered_baseq2';


SELECT l_returnflag, l_linestatus,
SUM(l_quantity) AS sum_qty,
SUM(l_extendedprice) AS sum_price
FROM line_item_raw_clustered
WHERE YEAR(l_shipdate) = 1995 AND MONTH(l_shipdate) <= 3
GROUP BY l_returnflag, l_linestatus;

insert into baseq_runtimes   
SELECT query_tag, query_text,query_id, warehouse_size,
total_elapsed_time / 1000 AS seconds,
bytes_scanned, query_acceleration_bytes_scanned, query_acceleration_partitions_scanned,
bytes_written_to_result, rows_written_to_result,
 query_retry_time
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY(RESULT_LIMIT => 100))
WHERE query_tag ='clustered_baseq2' AND query_tag <> '' and query_text like 'SELECT l_returnflag,%' and execution_status ='SUCCESS'
ORDER BY start_time DESC;

select * from baseq_runtimes ; 


SELECT * FROM snowflake.account_usage.automatic_clustering_history
ORDER BY start_time DESC LIMIT 20;


----- clustered line raw 

ALTER SESSION SET USE_CACHED_RESULT = FALSE;
-- Clear the warehouse disk cache between tests:
ALTER WAREHOUSE wh_xs SUSPEND;
ALTER WAREHOUSE wh_xs RESUME;
ALTER SESSION SET QUERY_TAG = 'clustered_q2_wyr';


SELECT l_returnflag, l_linestatus,
SUM(l_quantity) AS sum_qty,
SUM(l_extendedprice) AS sum_price
FROM line_item_raw_clustered
WHERE YEAR(l_shipdate) between 1992 and 1998 AND MONTH(l_shipdate) between 1 and 12
GROUP BY l_returnflag, l_linestatus;

insert into baseq_runtimes   
SELECT query_tag, query_text,query_id, warehouse_size,
total_elapsed_time / 1000 AS seconds,
bytes_scanned, query_acceleration_bytes_scanned, query_acceleration_partitions_scanned,
bytes_written_to_result, rows_written_to_result,
 query_retry_time
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY(RESULT_LIMIT => 100))
WHERE query_tag ='clustered_q2_wyr' AND query_tag <> '' and query_text like 'SELECT l_returnflag,%' and execution_status ='SUCCESS'
ORDER BY start_time DESC;
