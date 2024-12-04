## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_LanePerformanceDailySummary.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Fact_LanePerformanceDailySummary
(
  dayid INT64 NOT NULL,
  laneid INT64,
  tripidentmethodid INT64,
  reasoncodeid INT64 NOT NULL,
  imagereviewedflag INT64,
  tollamount BIGNUMERIC(40, 2),
  txncount INT64
)
;