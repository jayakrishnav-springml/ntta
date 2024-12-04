## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Utility_PartitionSwitchLog.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.PartitionSwitchLog
(
  switchlogid INT64 NOT NULL,
  seqid INT64 NOT NULL,
  tablename STRING NOT NULL,
  partitionnum INT64 NOT NULL,
  numbervaluefrom INT64,
  numbervalueto INT64,
  datevaluefrom DATE,
  datevalueto DATE,
  row_count INT64,
  logdate DATETIME NOT NULL
)
;