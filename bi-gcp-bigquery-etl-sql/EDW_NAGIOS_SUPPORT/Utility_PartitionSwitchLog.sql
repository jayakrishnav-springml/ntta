-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/Utility_PartitionSwitchLog.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS_SUPPORT.PartitionSwitchLog
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
