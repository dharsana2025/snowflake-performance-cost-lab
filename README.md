# Snowflake Query Performance and Cost Optimization: Test Report

| | |
|---|---|
| Project type | Personal learning project (not production work) |
| Platform | Snowflake trial account ([aws]) |
| Test date | 26 October 2026 |
| Tools | Snowflake SQL, Snowsight, dbt (Snowflake adapter 1.9.2) |
| Status | Complete |

## 1. Executive summary

This report documents a hands-on evaluation of query performance and cost behaviour in Snowflake. The work covered partition pruning and clustering, warehouse sizing, credit consumption monitoring, column masking and incremental transformation with dbt. Every result is taken from Snowflake usage views (`QUERY_HISTORY`, `METERING_HISTORY`, `WAREHOUSE_EVENTS_HISTORY`) or from captured screenshots.

| Area | Result |
|---|---|
| Clustering | A 3-month date query scanned 5 of 88 partitions on the clustered table, against 92 of 92 on the unclustered table. Bytes scanned fell from 344.9 MB to 12.0 MB. |
| Warehouse sizing | A Medium warehouse ran three heavy queries 3.2 to 3.7 times faster than X-Small for 7% to 25% more estimated credits. |
| Credit consumption | The test day consumed about 10.6 credits, while query run time accounted for about 0.2. The difference came from warehouse start-up and idle time. |
| Clustering cost | Under 0.001 credits at the tested table size. |
| Governance | A masking policy returned real values to the engineer role and NULL to the analyst role. |

## 2. Goal and objectives

**Goal.** Measure, with repeatable tests and evidence from Snowflake's own usage views, how data layout, warehouse size and warehouse usage patterns affect performance and cost, and apply basic governance and incremental-load practices.

**Objectives.**

1. Quantify the effect of a clustering key on partitions and bytes scanned.
2. Compare X-Small, Small and Medium warehouses on heavy queries, in time and credits.
3. Monitor credit consumption, detect an unusual day, and identify its cause.
4. Restrict a sensitive column by role with a masking policy.
5. Build an incremental transformation with dbt.

## 3. Outcomes against objectives

| # | Objective | Outcome | Status |
|---|---|---|---|
| 1 | Clustering effect | Partitions scanned fell from 92 of 92 to 5 of 88 (about 95% fewer). Bytes scanned fell by about 96%. Average execution time fell from 0.68 s to 0.35 s. | Achieved |
| 2 | Warehouse sizing | Medium was 3.2 to 3.7 times faster than X-Small for 7% to 25% more estimated credits. Spilling to disk explained the larger gain in the join test. Some test cells have only 1 or 2 runs. | Achieved, limited runs |
| 3 | Cost monitoring | A daily anomaly query flagged the unusual day (10.59 credits against a previous average of 0.08). Warehouse event history traced the cost to repeated warehouse resumes. | Achieved |
| 4 | Masking | Engineer role sees account balances, analyst role sees NULL. | Achieved |
| 5 | Incremental dbt model | The model was built and re-run incrementally. Two data tests are defined. Test results were not recorded. | Achieved, test results not recorded |

## 4. Environment

- Snowflake trial account ([cloud], [region], [edition])
- Warehouses `WH_XS`, `WH_S`, `WH_M`: auto-suspend 60 seconds, statement timeout 1800 seconds, one resource monitor with a [quota]-credit quota
- Database `PERF_LAB`, schema `TPCH`, roles `ENGINEER_ROLE` and `ANALYST_ROLE`
- dbt project `lineitem_clustered_dbt`, run from Snowsight Workspaces

## 5. Test data

| Object | Description |
|---|---|
| `line_item_raw` | 59,986,052 rows copied from TPC-H SF10 `lineitem`. Loaded with `ORDER BY l_suppkey` so that ship dates are scattered across all 92 micro-partitions. The load took about 24 seconds on X-Small. |
| `line_item_raw_clustered` | The same data with a clustering key on `l_shipdate` (88 micro-partitions). |
| `orders`, `customer` | Copies of the TPC-H tables. |
| `snowflake_sample_data.tpch_sf100` | Queried directly for the warehouse sizing tests (about 600 million rows in `lineitem`). |

## 6. Methodology

- The result cache was disabled for every test (`USE_CACHED_RESULT = FALSE`).
- The warehouse was suspended and resumed before each test, so each run started cold.
- Each run carried a query tag. Each query ran 3 times, and the first clustered test ran 6 times.
- Metrics were taken from `SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY`, because the `INFORMATION_SCHEMA` version does not include partition or spill columns.
- Partitions scanned and bytes scanned are the primary evidence, because they do not vary between runs. Most queries completed in under 2 seconds, so timings carry noise.
- `PERCENTAGE_SCANNED_FROM_CACHE` was 0 on almost every run, so the warehouse disk cache did not explain differences between runs.

## 7. Results

### 7.1 Partition pruning and clustering (3-month filter, X-Small)

| Query | Table | Partitions scanned / total | Bytes scanned | Avg execution (s) | Avg total (s) | Runs |
|---|---|---|---|---|---|---|
| Q1 date range filter | raw | 92 / 92 | 344.9 MB | 0.68 | 0.83 | 3 |
| Q1 date range filter | clustered | 5 / 88 | 12.0 MB | 0.35 | 0.46 | 6 |
| Q2 `YEAR()` and `MONTH()` filter | raw | 92 / 92 | 344.9 MB | 0.80 | 1.00 | 3 |
| Q2 `YEAR()` and `MONTH()` filter | clustered | 6 / 88 | not recorded | 0.49 | 0.67 | 3 |
| Q3 three-table join | raw | 124 / 124 | 493.0 MB | 1.23 | 1.43 | 3 |
| Q4 window function | raw | 92 / 92 | 450.7 to 460.2 MB | 0.92 | 1.09 | 3 |

The `YEAR()` filter was expected to block pruning, but it still reached 6 of 88 partitions on the clustered table. No query spilled to disk in these tests.

### 7.2 Wide date range (1992 to 1998)

The full date range was run to compare timing when almost nothing can be skipped.

| Query | Table | Partitions scanned / total | Avg total (s) | Runs |
|---|---|---|---|---|
| Q1 | clustered | 88 / 88 | 0.89 | 4 |
| Q2 | raw | 92 / 92 | 0.83 | 3 |
| Q2 | clustered | 88 / 88 | 0.81 | 3 |

With a filter this wide, clustering gives no pruning benefit and does not slow the query.

### 7.3 Warehouse sizing (TPC-H SF100)

H1 is TPC-H Query 1 (full scan and aggregation), H2 is a four-table join with a distinct count, and H3 is a window function over all line items. Credits are estimated as hourly rate (XS 1, S 2, M 4) multiplied by elapsed seconds and divided by 3600.

| Query | Size | Runs | Avg elapsed (s) | Spilled to disk | Est. credits per run | Speed vs XS | Cost vs XS |
|---|---|---|---|---|---|---|---|
| H1 | XS | 3 | 7.74 | 4 KB (negligible) | 0.00215 | 1.0x | baseline |
| H1 | S | 3 | 4.30 | none | 0.00239 | 1.8x | +11% |
| H1 | M | 2 | 2.42 | none | 0.00268 | 3.2x | +25% |
| H2 | XS | 1 | 54.04 | 6.4 GB local | 0.0150 | 1.0x | baseline |
| H2 | S | 3 | 36.40 | 1.8 to 3.9 GB local | 0.0202 | 1.5x | +35% |
| H2 | M | 3 | 16.35 | none | 0.0182 | 3.3x | +21% |
| H3 | XS | 2 of 3 | 25.3 | 4.9 GB local | 0.0070 | 1.0x | baseline |
| H3 | S | 1 | 11.70 | none | 0.0065 | 2.2x | -7% |
| H3 | M | 4 | 6.79 | none | 0.0075 | 3.7x | +7% |

One of three H3 runs on X-Small took 46.3 seconds against about 25 for the other two. It was excluded from the average and its cause was not determined.

In H2, Medium was both faster and about 10% cheaper than Small. X-Small and Small spilled several GB to local disk, and Medium did not, which fits the Small-to-Medium speed-up (2.2x) exceeding the doubled credit rate.

### 7.4 Cost monitoring

Credits by service on 26 October (`METERING_HISTORY`):

| Service | Credits |
|---|---|
| `WH_M` | 6.79 |
| `WH_XS` | 3.09 |
| `WH_S` | 0.70 |
| `SQL_WH` | 0.26 |
| Automatic clustering on `LINE_ITEM_RAW_CLUSTERED` | under 0.001 |
| All other services | under 0.01 |

No serverless task credits were recorded.

A daily anomaly query flagged 26 October (10.59 credits against a previous average of 0.08). The first version of the query also flagged 16 October (0.23 credits against 0.0002), which was a false alarm, so a minimum of 1 credit was added: `credits > 2 * avg_prev_7 AND credits > 1`. The query averages the previous 7 rows rather than 7 calendar days, because days without usage have no row.

![Anomaly query](screenshots/cost_anomaly_query.png)

`WAREHOUSE_EVENTS_HISTORY` showed 113 resumes of `WH_XS` (70 manual), 12 of `WH_S` and at least 42 of `WH_M` on the test day. Each resume bills at least 60 seconds, and the warehouse then stays on for the 60-second auto-suspend period, so each short query cost roughly 100 seconds of warehouse time. In the 20:00 hour `WH_M` resumed 17 times automatically and consumed 3.07 credits, about 2.7 minutes of Medium per resume. The cause was interactive development queries (dbt, governance and monitoring) run on a Medium warehouse.

### 7.5 Governance

A masking policy on `customer.c_acctbal` returns real balances to `ENGINEER_ROLE` (for example 711.56 and 121.65) and NULL to `ANALYST_ROLE` for the same query.

![Engineer role](screenshots/masking_engineer_role.png)
![Analyst role](screenshots/masking_analyst_role.png)

### 7.6 dbt incremental model

The model `daily_revenue` joins `line_item_raw_clustered` with `orders`, sums discounted revenue by order date, and uses `is_incremental()` to load only newer order dates. The project contains 1 model, 2 data tests and 2 sources.

| Run | Model time | Whole run | dbt result |
|---|---|---|---|
| 21:59 | 2.25 s | 3.15 s | SUCCESS 1 |
| 22:54 | 1.59 s | 2.41 s | SUCCESS 0 |

The second run loaded nothing new because the sample data has no newer order dates. A `MERGE` statement (0.33 s) in the query history confirms that the incremental path ran.

![dbt run 21:59](screenshots/dbt_run_2159.png)
![dbt run 22:54](screenshots/dbt_run_2254.png)

## 8. Findings

1. Data layout determined scan cost. The unclustered table scanned every partition for every date filter, and clustering on `l_shipdate` reduced a 3-month filter to 5 partitions.
2. Pruning depends on the filter. A filter covering the full date range scanned every partition on both tables.
3. For heavy queries, a larger warehouse gave a large speed-up for a small increase in credits. For short queries, X-Small is the appropriate size because start-up and idle time dominate.
4. Billed credits were far above query run time. Most of the cost came from warehouse resumes and idle time before auto-suspend.
5. A daily query on `ACCOUNT_USAGE` was sufficient to flag the unusual day, and the events view explained it.
6. A masking policy restricted a sensitive column by role without changing the table.

## 9. Limitations

- The pruning tables are small (92 micro-partitions). Clustering normally matters most on much larger tables, and its cost was measured on this small table only.
- Pruning-test queries ran for under 2 seconds, so timings are noisy. Some sizing cells have only 1 or 2 runs.
- Credits in section 7.3 are estimates from run time. Billed credits are in section 7.4.
- An incremental dbt run was not compared with a full rebuild, and the dbt test results were not recorded.
- Single trial account, single user, no concurrent load.

## 10. Recommendations and next steps

- Choose clustering keys on frequently filtered columns of large tables, and measure the reclustering cost.
- Size warehouses by comparing the time ratio with the credit-rate ratio, and use X-Small for ad-hoc, monitoring and dbt work.
- Keep auto-suspend at 60 seconds, group queries into bursts, and set a resource monitor quota.
- Run a daily anomaly query with a minimum threshold to avoid false alarms.
- Apply masking policies to sensitive columns and verify them by switching roles.
- Next steps: record the dbt test results, compare an incremental run with a full refresh, repeat the clustering test on a larger table, and add a Python script that runs the query files and records query IDs.

## 11. Repository contents

```
README.md
sql/            setup, data load, test queries, optimizations, cost monitoring, governance
dbt/            lineitem_clustered_dbt project (models, sources, dbt_project.yml)
screenshots/    evidence for sections 7.4 to 7.6
```

Credentials, account identifiers and dbt `profiles.yml` are not committed.
