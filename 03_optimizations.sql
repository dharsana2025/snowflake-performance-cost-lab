-- Experiment A: Rewrite the predicate (q2 to q1 style)

select * from baseq_runtimes where query_tag in ('query_base_1', 'query_base_2');

 /** query 1 had taken 0.68 seconds in scanning when was using direct date range 
but query 2 had taken 0.99 second in scanning when was using functions in filter ;
so query 1 is better to use 
**/

--  Experiment B: Clustering Key : If the data is sorted by the column filter on, then snowflake skips most micro partitions

create or replace table line_item_raw_clustered cluster by (l_shipdate) as select * from line_item_raw order by l_shipdate;

set clustering_output = (
select system$clustering_information('line_item_raw_clustered', '(l_ship_date'));

select $clustering_output;

ALTER SESSION SET USE_CACHED_RESULT= FALSE;

ALTER WAREHOUSE wh_xs SUSPEND;

ALTER WAREHOUSE wh_xs RESUME;

ALTER SESSION SET query_tag='clustered_altered_q1'


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
WHERE query_tag ='clustered_altered' AND query_tag <> '' and query_text like 'SELECT l_returnflag,%' and execution_status ='SUCCESS'
ORDER BY start_time DESC;


SELECT * FROM snowflake.account_usage.automatic_clustering_history
ORDER BY start_time DESC LIMIT 20;



select min(l_shipdate) , max(l_shipdate) from line_item_raw;