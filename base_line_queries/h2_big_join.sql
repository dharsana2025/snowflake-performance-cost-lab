

ALTER SESSION SET USE_CACHED_RESULT= FALSE;

ALTER WAREHOUSE wh_xs SUSPEND;

ALTER WAREHOUSE wh_xs RESUME;

ALTER SESSION SET query_tag='h2_size_xs'


SELECT n.n_name AS nation, c.c_mktsegment, YEAR(o.o_orderdate) AS order_year,
       COUNT(DISTINCT o.o_orderkey) AS orders,
       SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM snowflake_sample_data.tpch_sf100.lineitem l
JOIN snowflake_sample_data.tpch_sf100.orders o   ON l.l_orderkey = o.o_orderkey
JOIN snowflake_sample_data.tpch_sf100.customer c ON o.o_custkey = c.c_custkey
JOIN snowflake_sample_data.tpch_sf100.nation n   ON c.c_nationkey = n.n_nationkey
GROUP BY n.n_name, c.c_mktsegment, YEAR(o.o_orderdate)
ORDER BY revenue DESC;






ALTER SESSION SET USE_CACHED_RESULT= FALSE;

ALTER WAREHOUSE wh_s SUSPEND;

ALTER WAREHOUSE wh_s RESUME;

ALTER SESSION SET query_tag='h2_size_s'


SELECT n.n_name AS nation, c.c_mktsegment, YEAR(o.o_orderdate) AS order_year,
       COUNT(DISTINCT o.o_orderkey) AS orders,
       SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM snowflake_sample_data.tpch_sf100.lineitem l
JOIN snowflake_sample_data.tpch_sf100.orders o   ON l.l_orderkey = o.o_orderkey
JOIN snowflake_sample_data.tpch_sf100.customer c ON o.o_custkey = c.c_custkey
JOIN snowflake_sample_data.tpch_sf100.nation n   ON c.c_nationkey = n.n_nationkey
GROUP BY n.n_name, c.c_mktsegment, YEAR(o.o_orderdate)
ORDER BY revenue DESC;



ALTER SESSION SET USE_CACHED_RESULT= FALSE;

ALTER WAREHOUSE wh_m SUSPEND;

ALTER WAREHOUSE wh_m RESUME;

ALTER SESSION SET query_tag='h2_size_m'


SELECT n.n_name AS nation, c.c_mktsegment, YEAR(o.o_orderdate) AS order_year,
       COUNT(DISTINCT o.o_orderkey) AS orders,
       SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM snowflake_sample_data.tpch_sf100.lineitem l
JOIN snowflake_sample_data.tpch_sf100.orders o   ON l.l_orderkey = o.o_orderkey
JOIN snowflake_sample_data.tpch_sf100.customer c ON o.o_custkey = c.c_custkey
JOIN snowflake_sample_data.tpch_sf100.nation n   ON c.c_nationkey = n.n_nationkey
GROUP BY n.n_name, c.c_mktsegment, YEAR(o.o_orderdate)
ORDER BY revenue DESC;
