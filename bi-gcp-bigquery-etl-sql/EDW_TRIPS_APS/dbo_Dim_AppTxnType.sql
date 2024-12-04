## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_AppTxnType.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_AppTxnType
(
  apptxntypeid INT64 NOT NULL,
  apptxntypecode STRING NOT NULL,
  apptxntypedesc STRING,
  effected_balancetype_positive STRING,
  effected_balancetype_negative STRING,
  main_balance_type STRING,
  txntypecategoryid INT64 NOT NULL,
  txntypecategory STRING,
  txntypeparentcategoryid INT64 NOT NULL,
  txntypeparentcategory STRING,
  edw_updatedate TIMESTAMP NOT NULL
)
CLUSTER BY apptxntypeid
;