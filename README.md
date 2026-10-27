# Snowflake Performance and Cost Test Report

| | |
|---|---|
| Author | Dharsana |
| Type | Personal learning project (not production work) |
| Platform | Snowflake trial account: [fill in cloud and region], [fill in edition] |
| Test date | 26 October 2026 |
| Status | Complete |

## 1. Summary

I wanted to see for myself how data layout, warehouse size and everyday warehouse habits change query performance and cost in Snowflake. So I built a small test lab and measured it. The pruning tests use about 60 million rows of TPC-H sample data. The warehouse size tests use the 600-million-row SF100 version.

| Area | Result |
|---|---|
| Clustering | A 3-month date query scanned 5 of 88 partitions after clustering, against 92 of 92 before. Bytes scanned fell from 344.9 MB to 12.0 MB. |
| Warehouse size | Medium ran the heavy queries 3.2 to 3.7 times faster than X-Small for 7% to 25% more estimated credits. |
| Daily cost | The test day used about 10.6 credits. The queries themselves needed about 0.2. The rest was warehouse start-up and idle time. |
| Clustering cost | Under 0.001 credits at this table size. |

## 2. Objective and scope

Questions I set out to answer:

1. Does clustering on the filter column reduce the partitions a query scans?
2. How does warehouse size change run time and credits for heavy queries?
3. Where do credits actually go, and can I catch an unusual day with a query?
4. Can a masking policy hide a sensitive column from one role but not another?

Not covered: concurrency, multi-cluster warehouses, real production data, and tables much bigger than the ones here.

## 3. Environment

- Snowflake trial account, [fill in cloud and region], [fill in edition]
- Warehouses `WH_XS`, `WH_S`, `WH_M`: auto-suspend 60 seconds, statement timeout 1800 seconds, one resource monitor with a [fill in]-credit quota
- Database `PERF_LAB`, schema `TPCH`, roles `ENGINEER_ROLE` and `ANALYST_ROLE`
- dbt project `lineitem_clustered_dbt`, run from Snowsight Workspaces (adapter snowflake 1.9.2)

## 4. Test data

| Object | Description |
|---|---|
| `line_item_raw` | 59,986,052 rows copied from TPC-H SF10 `lineitem`. I loaded it with `ORDER BY l_suppkey` on purpose, so ship dates are scattered across all 92 micro-partitions. The load took about 24 seconds on X-Small. |
| `line_item_raw_clustered` | The same data with a clustering key on `l_shipdate` (88 micro-partitions). |
| `orders`, `customer` | Copies of the TPC-H tables. |
| `snowflake_sample_data.tpch_sf100` | Used directly for the warehouse size tests (about 600 million rows in `lineitem`). |

## 5. Test method

- Result cache off for every test (`USE_CACHED_RESULT = FALSE`).
- I suspended and resumed the warehouse before each test, so each run starts cold.
- Every run has a query tag. Each query ran 3 times, and the first clustered test ran 6 times.
- Numbers come from `SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY`. The `INFORMATION_SCHEMA` version does not have the partition or spill columns.
- Partitions scanned and bytes scanned are my main evidence, because they stay the same from run to run. Most queries finish in under 2 seconds, so the timings are noisy.
- `PERCENTAGE_SCANNED_FROM_CACHE` was 0 on almost every run, so the warehouse disk cache did not explain the small differences between runs.

## 6. Results

### 6.1 Partition pruning and clustering (3-month filter, X-Small)

| Query | Table | Partitions scanned / total | Bytes scanned | Avg execution (s) | Avg total (s) | Runs |
|---|---|---|---|---|---|---|
| Q1 date range filter | raw | 92 / 92 | 344.9 MB | 0.68 | 0.83 | 3 |
| Q1 date range filter | clustered | 5 / 88 | 12.0 MB | 0.35 | 0.46 | 6 |
| Q2 `YEAR()` and `MONTH()` filter | raw | 92 / 92 | 344.9 MB | 0.80 | 1.00 | 3 |
| Q2 `YEAR()` and `MONTH()` filter | clustered | 6 / 88 | not recorded | 0.49 | 0.67 | 3 |
| Q3 three-table join | raw | 124 / 124 | 493.0 MB | 1.23 | 1.43 | 3 |
| Q4 window function | raw | 92 / 92 | 450.7 to 460.2 MB | 0.92 | 1.09 | 3 |

Pruning cut partitions scanned by about 95% and bytes scanned by about 96%. I expected the `YEAR()` filter to block pruning, but it still reached 6 of 88 partitions on the clustered table. Nothing spilled to disk in these tests.

### 6.2 Wide date range (1992 to 1998)

I ran the full date range to compare timing when almost nothing can be skipped.

| Query | Table | Partitions scanned / total | Avg total (s) | Runs |
|---|---|---|---|---|
| Q1 | clustered | 88 / 88 | 0.89 | 4 |
| Q2 | raw | 92 / 92 | 0.83 | 3 |
| Q2 | clustered | 88 / 88 | 0.81 | 3 |

With a filter this wide, clustering gives no pruning benefit, and it did not slow the query down either.

### 6.3 Warehouse size (TPC-H SF100)

H1 is TPC-H Query 1 (full scan and aggregation), H2 is a four-table join with a distinct count, and H3 is a window function over all line items. Credits are estimated as hourly rate (XS 1, S 2, M 4) times elapsed seconds divided by 3600.

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

One of the three H3 runs on X-Small took 46.3 seconds while the other two took about 25. I left it out of the average and I do not know why it was slow.

For H2, Medium was both faster and about 10% cheaper than Small. X-Small and Small spilled several GB to local disk on H2, and Medium did not, which fits the speed-up from Small to Medium (2.2x) being bigger than the doubled credit rate.

### 6.4 Cost monitoring

Credits by service on 26 October (`METERING_HISTORY`):

| Service | Credits |
|---|---|
| `WH_M` | 6.79 |
| `WH_XS` | 3.09 |
| `WH_S` | 0.70 |
| `SQL_WH` | 0.26 |
| Automatic clustering on `LINE_ITEM_RAW_CLUSTERED` | under 0.001 |
| Everything else | under 0.01 |

No serverless task credits appear, so no task was running.

My daily anomaly query flagged 26 October (10.59 credits against a previous average of 0.08). The first version also flagged 16 October (0.23 credits against 0.0002), which was a false alarm, so I added a minimum of 1 credit: `credits > 2 * avg_prev_7 AND credits > 1`. The query averages the previous 7 rows, not 7 calendar days, because days without usage have no row.

![Anomaly query](screenshots/cost_anomaly_query.png)

To find the cause I checked `WAREHOUSE_EVENTS_HISTORY`. On 26 October there were 113 resumes of `WH_XS` (70 manual), 12 of `WH_S` and at least 42 of `WH_M`. Each resume bills at least 60 seconds, and the warehouse then stays on for the 60-second auto-suspend, so each short query cost roughly 100 seconds of warehouse time. In the 20:00 hour `WH_M` resumed 17 times by itself and used 3.07 credits, about 2.7 minutes of Medium each time. Those were my own queries from that hour, run on a Medium warehouse that should have been X-Small.

### 6.5 Governance

I put a masking policy on `customer.c_acctbal`. With `ENGINEER_ROLE` the query returns the real balances (for example 711.56 and 121.65). With `ANALYST_ROLE` the same query returns NULL.

![Engineer role](screenshots/masking_engineer_role.png)
![Analyst role](screenshots/masking_analyst_role.png)

### 6.6 dbt incremental model

The model `daily_revenue` joins `line_item_raw_clustered` with `orders`, sums discounted revenue by order date, and uses `is_incremental()` to load only newer order dates. The project has 1 model, 2 data tests and 2 sources.

| Run | Model time | Whole run | dbt result |
|---|---|---|---|
| 21:59 | 2.25 s | 3.15 s | SUCCESS 1 |
| 22:54 | 1.59 s | 2.41 s | SUCCESS 0 |

The second run added nothing because the sample data has no newer order dates. A `MERGE` statement (0.33 s) in the query history shows the incremental path ran.

![dbt run 21:59](screenshots/dbt_run_2159.png)
![dbt run 22:54](screenshots/dbt_run_2254.png)

## 7. Findings

1. Data layout decided the scan cost. The unclustered table scanned every partition for every date filter. After clustering on `l_shipdate`, a 3-month filter scanned 5.
2. Pruning depends on the filter. A filter covering the whole date range scanned every partition on both tables.
3. For heavy queries, a bigger warehouse was much faster for a small increase in credits. For short queries, X-Small is the right size because start-up and idle time dominate.
4. Billed credits were far above the query run time. Most of the cost came from warehouse resumes and the idle time before auto-suspend, not from the queries.
5. A simple daily query on `ACCOUNT_USAGE` was enough to flag the unusual day, and the events view explained it.
6. A masking policy hid the balance column from the analyst role without changing the table.

## 8. Limitations

- The pruning tables are small (92 micro-partitions). Clustering usually matters most on much larger tables.
- Queries ran for under 2 seconds in the pruning tests, so timings are noisy. Some warehouse test cells have only 1 or 2 runs.
- Credits in section 6.3 are estimates from run time. Billed credits are in section 6.4.
- Clustering cost was measured on this small table only.
- I did not compare an incremental dbt run against a full rebuild, and the dbt tests were defined but I did not record their results here.
- Trial account, one user, no concurrent load.

## 9. Possible next steps

- A Python script that runs the query files and records the query IDs
- Record the dbt test results and compare an incremental run with a full refresh
- Repeat the clustering test on a larger table

## 10. Repository contents

```
README.md
sql/            setup, data load, test queries, optimizations, cost monitoring, governance
dbt/            lineitem_clustered_dbt project (models, sources, dbt_project.yml)
screenshots/    evidence for sections 6.4 to 6.6
```

Passwords, account names and dbt `profiles.yml` credentials are not committed.
