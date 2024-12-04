-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/dbo_Dim_State.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS.Dim_State
(
  state_id INT64 NOT NULL,
  object_type STRING,
  state_value INT64,
  state_desc STRING NOT NULL,
  edw_updatedate DATETIME
)
cluster by state_id
;
