-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/Stage_Host_Service_Metric_Data3.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS_STAGE.Host_Service_Metric_Data3
(
  host_service_event_id INT64 NOT NULL,
  host STRING,
  service STRING,
  host_service_state INT64 NOT NULL,
  metric_string STRING,
  metric_count INT64,
  metric_index INT64 NOT NULL,
  metric_name STRING,
  value_string STRING
)
;