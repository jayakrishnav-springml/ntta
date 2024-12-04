-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/Stage_Host_Service_Metric_Data.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS_STAGE_APS.Host_Service_Metric_Data
(
  host_service_event_id INT64 NOT NULL,
  event_date DATETIME NOT NULL,
  nagios_object_id INT64 NOT NULL,
  host_type STRING,
  host STRING,
  service STRING,
  host_service_state INT64 NOT NULL,
  event_info STRING,
  metric_string STRING,
  metric_index INT64 NOT NULL,
  metric_suffix INT64,
  metric_name STRING,
  metric_value NUMERIC(37, 8),
  metric_unit STRING,
  warning_value NUMERIC(37, 8),
  critical_value NUMERIC(37, 8),
  min_value NUMERIC(37, 8),
  max_value NUMERIC(37, 8),
  metric_state INT64 NOT NULL,
  percent_warning NUMERIC(31, 2),
  percent_critical NUMERIC(31, 2),
  percent_max NUMERIC(31, 2),
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)
;
