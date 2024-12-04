-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/dbo_Fact_Host_Service_Event_Metric_Summary_OLD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS.Fact_Host_Service_Event_Metric_Summary_Old
(
  event_metric_summary_id INT64 NOT NULL,
  event_day_id INT64 NOT NULL,
  host_service_metric_id INT64 NOT NULL,
  metric_state_id INT64 NOT NULL,
  metric_unit STRING,
  total_metric_value NUMERIC(37, 8),
  metric_value_count INT64,
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)
cluster by event_metric_summary_id
;
