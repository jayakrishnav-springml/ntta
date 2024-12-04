-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/dbo_Fact_Host_Service_Event_Summary_OLD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS.Fact_Host_Service_Event_Summary_Old
(
  event_summary_id INT64 NOT NULL,
  event_day_id INT64 NOT NULL,
  nagios_object_id INT64 NOT NULL,
  host_service_state_id INT64 NOT NULL,
  event_count INT64 NOT NULL,
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)
cluster by event_summary_id
;
