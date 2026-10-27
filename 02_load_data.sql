USE ROLE ENGINEER_ROLE;

USE WAREHOUSE wh_xs;
USE SCHEMA perf_lab.tpch;

CREATE OR REPLACE TABLE customer as SELECT * FROM
snowflake_sample_data.tpch_sf10.customer;

CREATE OR REPLACE TABLE orders as SELECT * FROM 
snowflake_sample_data.tpch_sf10.orders;

-- Sorted by supplierkey purposely, SO that ship_date is scattered across partitions

-- 24 seconds taken to load this table 
CREATE OR REPLACE TABLE line_item_raw as 
SELECT * FROM snowflake_sample_data.tpch_sf10.lineitem
ORDER BY l_suppkey;


---  around 60 M rows

select concat(round(count(*)/ 1000000,0),' ', 'M') as tot_rows from line_item_raw;

-- 59986052





