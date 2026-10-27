create or replace table heavy_wh_runtime as 
SELECT query_tag, query_text,query_id, warehouse_size,
total_elapsed_time / 1000 AS seconds,
bytes_scanned, query_acceleration_bytes_scanned, query_acceleration_partitions_scanned,
bytes_written_to_result, rows_written_to_result,
query_retry_time
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY(RESULT_LIMIT => 400))
WHERE query_tag in ('h1_size_xs' , 'h1_size_wh_m','h1_size_wh_s','h2_size_s' ,'h2_size_xs','h2_size_m','h3_size_xs','h3_size_s','h3_size_m') and execution_status ='SUCCESS'
and (query_text ilike  'SELECT l_returnflag, %' or query_text ilike 'SELECT n.n_name%' or query_text ilike 'SELECT l_suppkey%')
ORDER BY start_time DESC;


select * from heavy_wh_runtime

-- 'h2_size_xs' , 'h2_size_s','h2_size_m',
--'h3_size_xs' , 'h3_size_s','h3_size_m')
-- and query_text ILIKE 'SELECT l_returnflag, l_linestatus %'

-- or query_text like 'SELECT n.n_name%' or query_text like '%l_linestatus ')

drop table wh_timing;

create table wh_timing as 
SELECT
    start_time,warehouse_name,
    query_tag,
    total_elapsed_time / 1000 AS seconds,
     avg(total_elapsed_time / 1000) over(partition by query_tag) as avg_seconds_q, 
    compilation_time / 1000 AS compile_s,
    execution_time / 1000 AS exec_s,
    percentage_scanned_from_cache,
    partitions_scanned,
    partitions_total , bytes_spilled_to_local_storage,
    bytes_spilled_to_remote_storage
FROM snowflake.account_usage.query_history
WHERE query_id IN (
    '01c80033-000e-1fa0-0002-b1660015319a',
    '01c80031-000e-1f4e-0002-b1660014b12e',
    '01c80031-000e-1fa0-0002-b16600153186',
    '01c8002f-000e-1faa-0002-b1660016a3ce',
    '01c8002d-000e-1fa7-0002-b1660015911e',
    '01c8002d-000e-1fb4-0002-b1660015f116',
    '01c8002d-000e-1fae-0002-b1660016313e',
    '01c8002c-000e-1f88-0002-b16600165112',
    '01c80029-000e-1fa0-0002-b1660015315e',
    '01c80028-000e-1fb8-0002-b1660015d102',
    '01c80028-000e-1fae-0002-b16600163126',
    '01c80026-000e-1f9b-0002-b1660015412e',
    '01c80025-000e-1f52-0002-b166001470e2',
    '01c80024-000e-1f88-0002-b166001650ea',
    '01c80021-000e-1f9d-0002-b1660014f0ea',
    '01c8001f-000e-1f87-0002-b1660014c0de',
    '01c8001f-000e-1fae-0002-b16600163116',
    '01c8001e-000e-1f9d-0002-b1660014f0da',
    '01c8001d-000e-1fae-0002-b1660016310a',
    '01c8001d-000e-1f4e-0002-b1660014b0f6',
    '01c8001c-000e-1fb8-0002-b1660015d0d6',
    '01c8001b-000e-1f52-0002-b166001470c2',
    '01c80017-000e-1f9b-0002-b16600154102'
)
AND execution_status = 'SUCCESS'
AND start_time >= DATEADD('day', -1, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;





-- 01c80023-000e-1f95-0002-b166001640be
-- 01c8002e-000e-1f52-0002-b1660014710e
select * from heavy_wh_runtime where query_tag = 'h3_size_m' and warehouse_size='Small';




