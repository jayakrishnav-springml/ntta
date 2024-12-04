## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_RecordType.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_RecordType
(
  recordtypeid INT64,
  recordtype STRING,
  recordformat STRING,
  sourceofentry INT64,
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)
CLUSTER BY recordtypeid
;