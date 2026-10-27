ALTER SESSION SET USE_CACHED_RESULT = FALSE;
-- Clear the warehouse disk cache between tests:
ALTER WAREHOUSE wh_xs SUSPEND;
ALTER WAREHOUSE wh_xs RESUME;
ALTER SESSION SET QUERY_TAG = 'query_base_3';



SELECT c.c_mktsegment,
SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM line_item_raw l
JOIN orders o ON l.l_orderkey = o.o_orderkey
JOIN customer c ON o.o_custkey = c.c_custkey
WHERE o.o_orderdate >= '1995-01-01' AND o.o_orderdate < '1996-01-01'
GROUP BY c.c_mktsegment
ORDER BY revenue DESC;


insert into  baseq_runtimes 
SELECT query_tag, query_text,query_id, warehouse_size,
total_elapsed_time / 1000 AS seconds,
bytes_scanned, query_acceleration_bytes_scanned, query_acceleration_partitions_scanned,
bytes_written_to_result, rows_written_to_result,
 query_retry_time
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY(RESULT_LIMIT => 100))
WHERE query_tag ='query_base_3' AND query_tag <> '' and query_text like 'SELECT c.c_mktsegment,%' and execution_status ='SUCCESS'
ORDER BY start_time DESC;


