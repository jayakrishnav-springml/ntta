-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/Stage_Host_Service_Metric_Data1.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS_STAGE.Host_Service_Metric_Data1
(
  host_service_event_id INT64 NOT NULL,
  host_service_state INT64 NOT NULL,
  host STRING,
  service STRING,
  metric_string STRING,
  metric_count INT64,
  eq_1 INT64,
  eq_2 INT64,
  eq_3 INT64,
  eq_4 INT64,
  eq_5 INT64,
  eq_6 INT64,
  eq_7 INT64,
  eq_8 INT64,
  eq_9 INT64,
  eq_10 INT64,
  eq_11 INT64,
  eq_12 INT64,
  eq_13 INT64,
  eq_14 INT64,
  eq_15 INT64,
  eq_16 INT64,
  eq_17 INT64
)
;
