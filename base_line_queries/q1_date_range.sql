ALTER SESSION SET USE_CACHED_RESULT= FALSE;

-- Clear the warehouse disk cache between tests
ALTER WAREHOUSE wh_xs SUSPEND;

ALTER WAREHOUSE wh_xs RESUME;

ALTER SESSION SET QUERY_TAG = 'query_base_1';

SELECT l_returnflag, l_linestatus,
SUM(l_quantity) AS sum_qty,
SUM(l_extendedprice) AS sum_price
FROM line_item_raw
WHERE l_shipdate >= '1992-01-01' AND l_shipdate < '1995-04-01'
GROUP BY l_returnflag, l_linestatus;


ALTER SESSION SET USE_CACHED_RESULT= FALSE;

ALTER WAREHOUSE wh_xs SUSPEND;

ALTER WAREHOUSE wh_xs RESUME;

ALTER SESSION SET query_tag='query_base1_wyr'


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
WHERE query_tag ='query_base1_wyr' and query_text like 'SELECT l_returnflag,%' and execution_status ='SUCCESS'
ORDER BY start_time DESC;


select * from baseq_runtimes;



select * from  TABLE(INFORMATION_SCHEMA.QUERY_HISTORY(RESULT_LIMIT => 100));

select max(l_shipdate) as max_, min(l_shipdate) as min_ from line_item_raw ;




SELECT start_time, query_tag,
       total_elapsed_time / 1000 AS seconds,
       compilation_time / 1000 AS compile_s,
       execution_time / 1000 AS exec_s,
       percentage_scanned_from_cache,
       partitions_scanned, partitions_total
FROM snowflake.account_usage.query_history
WHERE query_id in (
'01c7fd97-000e-1e99-0002-b1660012c836',
'01c7fd96-000e-1eeb-0002-b16600135792',
'01c7fd94-000e-1efb-0002-b1660013b036',
'01c7fd9a-000e-1f2d-0002-b166001387ce',
'01c7fd9a-000e-1ecb-0002-b1660012e816',
'01c7fd9f-000e-1efb-0002-b1660013b0ee',
'01c7fd9e-000e-1f2d-0002-b1660013881a',
'01c7fdde-000e-1eeb-0002-b16600135a6e',
'01c7fdde-000e-1e99-0002-b1660012caba',
'01c7fdee-000e-1f2d-0002-b16600138b1e',
'01c7fdee-000e-1efb-0002-b1660013b3a2',
'01c7fdea-000e-1e99-0002-b1660012cb9e',
'01c7fff2-000e-1f90-0002-b1660015e04e',
'01c7fff2-000e-1f95-0002-b1660016403e',
'01c7fff2-000e-1fa6-0002-b1660015c04a',
'01c7fff7-000e-1f87-0002-b1660014c052',
'01c7fff7-000e-1f9b-0002-b1660015409a',
'01c7fff6-000e-1f89-0002-b1660014e082',
'01c7fff9-000e-1fa3-0002-b16600155096',
'01c7fffd-000e-1fa4-0002-b16600157062',
'01c7fffc-000e-1fa1-0002-b16600166066',
'01c7fded-000e-1e7c-0002-b1660013e2de',
'01c7fde9-000e-1f63-0002-b1660013c35a',
'01c7ffee-000e-1f71-0002-b16600148092',
'01c7ffee-000e-1f4b-0002-b1660014607a',
'01c7fd99-000e-1efb-0002-b1660013b08a',
'01c7fff1-000e-1f4e-0002-b1660014b08a',
'01c7fff9-000e-1fa0-0002-b16600153082',
'01c7fd9f-000e-1f63-0002-b1660013c06a',
'01c7fdea-000e-1f2d-0002-b16600138ac2',
'01c7ffee-000e-1fa4-0002-b1660015704e',
'01c7fff9-000e-1fb8-0002-b1660015d072',
'01c7fffd-000e-1f71-0002-b166001480e6',
'01c7fddd-000e-1e99-0002-b1660012caae') and execution_status ='SUCCESS'
  AND start_time >= DATEADD('day', -1, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;

select * from snowflake.account_usage.query_history limit 10;



select distinct query_id from baseq_runtimes;