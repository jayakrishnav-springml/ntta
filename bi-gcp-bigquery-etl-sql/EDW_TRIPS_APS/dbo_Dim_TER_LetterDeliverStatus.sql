## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_TER_LetterDeliverStatus.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_TER_LetterDeliverStatus
(
  letterdeliverstatusid INT64 NOT NULL,
  letterdeliverstatuscode STRING,
  letterdeliverstatusdesc STRING,
  l1_lookuptypecodeid INT64 NOT NULL,
  l1_lookuptypecode STRING,
  l1_lookuptypecodedesc STRING,
  edw_updatedate DATETIME
)
cluster by letterdeliverstatusid
;