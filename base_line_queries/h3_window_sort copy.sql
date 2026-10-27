ALTER SESSION SET USE_CACHED_RESULT= FALSE;

ALTER WAREHOUSE wh_m SUSPEND;

ALTER WAREHOUSE wh_m RESUME;

ALTER SESSION SET query_tag='h3_size_m'


SELECT l_suppkey, l_orderkey, l_extendedprice,
       ROW_NUMBER() OVER (PARTITION BY l_suppkey ORDER BY l_extendedprice DESC) AS rn
FROM snowflake_sample_data.tpch_sf100.lineitem
QUALIFY rn <= 3;





ALTER SESSION SET USE_CACHED_RESULT= FALSE;

ALTER WAREHOUSE wh_s SUSPEND;

ALTER WAREHOUSE wh_s RESUME;

ALTER SESSION SET query_tag='h3_size_s';


SELECT l_suppkey, l_orderkey, l_extendedprice,
       ROW_NUMBER() OVER (PARTITION BY l_suppkey ORDER BY l_extendedprice DESC) AS rn
FROM snowflake_sample_data.tpch_sf100.lineitem
QUALIFY rn <= 3;





ALTER SESSION SET USE_CACHED_RESULT= FALSE;

ALTER WAREHOUSE wh_xs SUSPEND;

ALTER WAREHOUSE wh_xs RESUME;

ALTER SESSION SET query_tag='h3_size_xs';


SELECT l_suppkey, l_orderkey, l_extendedprice,
       ROW_NUMBER() OVER (PARTITION BY l_suppkey ORDER BY l_extendedprice DESC) AS rn
FROM snowflake_sample_data.tpch_sf100.lineitem
QUALIFY rn <= 3;


