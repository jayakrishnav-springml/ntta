-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/Temp_Host_Service_Metric.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS_DELETE.Host_Service_Metric
(
  nagios_object_id INT64 NOT NULL,
  service STRING,
  metric_name STRING,
  metric_suffix INT64,
  metric_target STRING,
  lnd_updatedate DATETIME
)
;
