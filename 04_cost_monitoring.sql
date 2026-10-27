---Credit usage by warehouse and day

SELECT warehouse_name,
DATE_TRUNC('day', start_time) AS usage_date,
SUM(credits_used) AS credits
FROM snowflake.account_usage.warehouse_metering_history
WHERE start_time >= DATEADD('day', -30, CURRENT_TIMESTAMP()) and warehouse_name in ('WH_XS', 'WH_S', 'WH_M')
GROUP BY 1, 2
ORDER BY usage_date DESC, credits DESC;

--- Slowest queries of the last 7 days 

SELECT query_tag,query_text, warehouse_name, warehouse_size,
total_elapsed_time / 1000 AS seconds,
bytes_scanned, partitions_scanned, partitions_total
FROM snowflake.account_usage.query_history
WHERE start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
AND warehouse_name IS NOT NULL
ORDER BY total_elapsed_time DESC
LIMIT 20;

-- create anamoly flag

WITH daily AS (
SELECT DATE_TRUNC('day', start_time) AS usage_date, SUM(credits_used) AS credits FROM snowflake.account_usage.warehouse_metering_history
WHERE start_time >= DATEADD('day', -30, CURRENT_TIMESTAMP()) GROUP BY 1 ), scored AS ( SELECT usage_date, credits, AVG(credits) OVER (ORDER BY usage_date ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS avg_prev_7 FROM daily)

SELECT usage_date, credits, avg_prev_7, credits > 2 * avg_prev_7 AND credits > 1   AS
is_anomaly
FROM scored
ORDER BY usage_date;



SELECT start_time, query_type, LEFT(query_text, 200) AS query_text, total_elapsed_time / 1000 AS seconds
FROM snowflake.account_usage.query_history
WHERE warehouse_name iLIKE 'COMPUTE_SERVICE_WH_USER_TASKS%'
ORDER BY start_time DESC LIMIT 20;
SELECT task_name, SUM(credits_used) AS credits, MIN(start_time) AS first_run, MAX(end_time) AS last_run
FROM snowflake.account_usage.serverless_task_history
-- WHERE start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY task_name;


SELECT service_type, name, ROUND(SUM(credits_used), 3) AS credits,
       MIN(start_time) AS first_use, MAX(end_time) AS last_use
FROM snowflake.account_usage.metering_history
WHERE start_time >= DATEADD('day', -2, CURRENT_TIMESTAMP())
GROUP BY service_type, name
ORDER BY credits DESC;


SELECT service_type, name, ROUND(SUM(credits_used), 3) AS credits,
       MIN(start_time) AS first_use, MAX(end_time) AS last_use
FROM snowflake.account_usage.metering_history
WHERE start_time >= DATEADD('day', -2, CURRENT_TIMESTAMP())
GROUP BY service_type, name
ORDER BY credits DESC;

SELECT warehouse_name, DATE_TRUNC('hour', timestamp) AS hr,
       event_name, event_reason, COUNT(*) AS n
FROM snowflake.account_usage.warehouse_events_history
WHERE timestamp >= '2026-10-26 00:00:00'::TIMESTAMP_LTZ
  AND warehouse_name IN ('WH_XS','WH_S','WH_M')
GROUP BY 1, 2, 3, 4
ORDER BY 1, 2, 3;

SHOW WAREHOUSES;