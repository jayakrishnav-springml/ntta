## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Utility_PartitionSwitchLog.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.PartitionSwitchLog
(
  switchlogid INT64 NOT NULL,
  seqid INT64 NOT NULL,
  tablename STRING NOT NULL,
  partitionnum INT64 NOT NULL,
  numbervaluefrom INT64,
  numbervalueto INT64,
  datevaluefrom DATE,
  datevalueto DATE,
  newrowcount INT64,
  tablerowcount INT64,
  actiontype STRING,
  logdate DATETIME NOT NULL
)
;