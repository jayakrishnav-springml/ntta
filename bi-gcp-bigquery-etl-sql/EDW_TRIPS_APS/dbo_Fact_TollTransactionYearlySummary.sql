## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_TollTransactionYearlySummary.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_TollTransactionYearlySummary
(
  yearid INT64,
  customerid INT64 NOT NULL,
  vehicletagid INT64 NOT NULL,
  custtagid INT64 NOT NULL,
  txncount INT64,
  tollsdue BIGNUMERIC(40, 2)
)
cluster by customerid
;