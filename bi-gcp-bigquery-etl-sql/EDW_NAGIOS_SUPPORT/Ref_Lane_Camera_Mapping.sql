-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/Ref_Lane_Camera_Mapping.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS_SUPPORT.Lane_Camera_Mapping
(
  controller STRING NOT NULL,
  metric_suffix INT64 NOT NULL,
  camera STRING,
  edw_updatedate DATETIME,
  mstr_updateuser STRING,
  mstr_updatedate DATETIME
)
cluster by metric_suffix
;
