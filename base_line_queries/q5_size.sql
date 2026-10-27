-- q5_heavy.sql

ALTER SESSION SET USE_CACHED_RESULT = FALSE;
-- Clear the warehouse disk cache between tests:
ALTER WAREHOUSE wh_xs SUSPEND;
ALTER WAREHOUSE wh_xs RESUME;
ALTER SESSION SET QUERY_TAG = 'size_q5_xs';



SELECT l_suppkey,
       COUNT(DISTINCT l_orderkey) AS orders,
       SUM(l_extendedprice * (1 - l_discount)) AS revenue
FROM line_item_raw
GROUP BY l_suppkey
ORDER BY revenue DESC
LIMIT 100;