-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/dbo_Fact_Host_Service_Event.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS.Fact_Host_Service_Event
(
  host_service_event_id INT64 NOT NULL,
  nagios_object_id INT64 NOT NULL,
  event_date DATETIME NOT NULL,
  event_day_id INT64 NOT NULL,
  event_time_id INT64 NOT NULL,
  host_service_state_id INT64 NOT NULL,
  metric_count INT64,
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)
;
