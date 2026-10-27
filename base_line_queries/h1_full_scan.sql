
ALTER SESSION SET USE_CACHED_RESULT= FALSE;

ALTER WAREHOUSE wh_xs SUSPEND;

ALTER WAREHOUSE wh_xs RESUME;

ALTER SESSION SET query_tag='h1_size_xs'

SELECT l_returnflag, l_linestatus,
       SUM(l_quantity) AS sum_qty,
       SUM(l_extendedprice) AS sum_price,
       SUM(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
       SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
       AVG(l_quantity) AS avg_qty,
       AVG(l_discount) AS avg_disc,
       COUNT(*) AS count_order
FROM snowflake_sample_data.tpch_sf100.lineitem
WHERE l_shipdate <= DATEADD('day', -90, '1998-12-01'::DATE)
GROUP BY l_returnflag, l_linestatus
ORDER BY l_returnflag, l_linestatus;






ALTER SESSION SET USE_CACHED_RESULT= FALSE;

ALTER WAREHOUSE wh_s SUSPEND;

ALTER WAREHOUSE wh_s RESUME;

ALTER SESSION SET query_tag='h1_size_wh_s'

SELECT l_returnflag, l_linestatus,
       SUM(l_quantity) AS sum_qty,
       SUM(l_extendedprice) AS sum_price,
       SUM(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
       SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
       AVG(l_quantity) AS avg_qty,
       AVG(l_discount) AS avg_disc,
       COUNT(*) AS count_order
FROM snowflake_sample_data.tpch_sf100.lineitem
WHERE l_shipdate <= DATEADD('day', -90, '1998-12-01'::DATE)
GROUP BY l_returnflag, l_linestatus
ORDER BY l_returnflag, l_linestatus;







ALTER SESSION SET USE_CACHED_RESULT= FALSE;

ALTER WAREHOUSE wh_m SUSPEND;

ALTER WAREHOUSE wh_m RESUME;

ALTER SESSION SET query_tag='h1_size_wh_m'

SELECT l_returnflag, l_linestatus,
       SUM(l_quantity) AS sum_qty,
       SUM(l_extendedprice) AS sum_price,
       SUM(l_extendedprice * (1 - l_discount)) AS sum_disc_price,
       SUM(l_extendedprice * (1 - l_discount) * (1 + l_tax)) AS sum_charge,
       AVG(l_quantity) AS avg_qty,
       AVG(l_discount) AS avg_disc,
       COUNT(*) AS count_order
FROM snowflake_sample_data.tpch_sf100.lineitem
WHERE l_shipdate <= DATEADD('day', -90, '1998-12-01'::DATE)
GROUP BY l_returnflag, l_linestatus
ORDER BY l_returnflag, l_linestatus;
