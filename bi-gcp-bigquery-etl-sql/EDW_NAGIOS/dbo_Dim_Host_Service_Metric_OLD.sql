-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/dbo_Dim_Host_Service_Metric_OLD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS.Dim_Host_Service_Metric_Old
(
  host_service_metric_id INT64,
  nagios_object_id INT64 NOT NULL,
  object_type STRING,
  host_facility STRING,
  host_plaza STRING,
  host_type STRING,
  host STRING,
  service STRING,
  plaza_latitude BIGNUMERIC(50, 12),
  plaza_longitude BIGNUMERIC(50, 12),
  is_active INT64,
  metric_name STRING,
  metric_suffix INT64,
  metric_target_type STRING,
  metric_target STRING,
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)
cluster by host_service_metric_id
;
