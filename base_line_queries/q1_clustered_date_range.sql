
ALTER SESSION SET USE_CACHED_RESULT= FALSE;

ALTER WAREHOUSE wh_xs SUSPEND;

ALTER WAREHOUSE wh_xs RESUME;

ALTER SESSION SET query_tag='clustered_altered_q1'


SELECT l_returnflag, l_linestatus,
SUM(l_quantity) AS sum_qty,
SUM(l_extendedprice) AS sum_price
FROM line_item_raw_clustered
WHERE l_shipdate >= '1995-01-01' AND l_shipdate < '1995-04-01'
GROUP BY l_returnflag, l_linestatus;

WHERE l_shipdate >= '1992-01-01' AND l_shipdate < '1998-12-31'







insert into  baseq_runtimes 
SELECT query_tag, query_text,query_id, warehouse_size,
total_elapsed_time / 1000 AS seconds,
bytes_scanned, query_acceleration_bytes_scanned, query_acceleration_partitions_scanned,
bytes_written_to_result, rows_written_to_result,
 query_retry_time
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY(RESULT_LIMIT => 100))
WHERE query_tag ='clustered_altered_q1' AND query_tag <> '' and query_text like 'SELECT l_returnflag,%' and execution_status ='SUCCESS'
ORDER BY start_time DESC;

select * from baseq_runtimes;

SELECT * FROM snowflake.account_usage.automatic_clustering_history
ORDER BY start_time DESC LIMIT 20





ALTER SESSION SET USE_CACHED_RESULT= FALSE;

ALTER WAREHOUSE wh_xs SUSPEND;

ALTER WAREHOUSE wh_xs RESUME;

ALTER SESSION SET query_tag='clustered_q1_wyr';


SELECT l_returnflag, l_linestatus,
SUM(l_quantity) AS sum_qty,
SUM(l_extendedprice) AS sum_price
FROM line_item_raw_clustered
WHERE l_shipdate >= '1992-01-01' AND l_shipdate < '1998-12-31'
GROUP BY l_returnflag, l_linestatus;



insert into  baseq_runtimes 
SELECT query_tag, query_text,query_id, warehouse_size,
total_elapsed_time / 1000 AS seconds,
bytes_scanned, query_acceleration_bytes_scanned, query_acceleration_partitions_scanned,
bytes_written_to_result, rows_written_to_result,
 query_retry_time
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY(RESULT_LIMIT => 100))
WHERE query_tag ='clustered_q1_wyr' AND query_tag <> '' and query_text like 'SELECT l_returnflag,%' and execution_status ='SUCCESS'




