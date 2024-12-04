## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_Fact_UnifiedTransaction_StaticSummary.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Fact_UnifiedTransaction_StaticSummary
(
  tripmonthid INT64,
  operationsmappingid INT64 NOT NULL,
  facilityid INT64 NOT NULL,
  txncount INT64,
  expectedamount NUMERIC(31, 2),
  adjustedexpectedamount NUMERIC(31, 2),
  calcadjustedamount NUMERIC(31, 2),
  tripwithadjustedamount NUMERIC(31, 2),
  tollamount NUMERIC(31, 2),
  actualpaidamount NUMERIC(31, 2),
  outstandingamount NUMERIC(31, 2),
  edw_updatedate TIMESTAMP NOT NULL
)
;