## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_CustomerPaymentLevel.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Dim_CustomerPaymentLevel
(
  customerpaymentlevelid INT64 NOT NULL,
  customerpaymentlevel1 STRING NOT NULL,
  customerpaymentlevel2 STRING NOT NULL,
  customerpaymentlevel3 STRING NOT NULL,
  customerpaymentlevel4 STRING,
  sortsequencenumber INT64 NOT NULL,
  edw_update_date DATETIME NOT NULL
)
CLUSTER BY customerpaymentlevelid
;