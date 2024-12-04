-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/dbo_Dim_Host_Service.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS_APS.Dim_Host_Service
(
  nagios_object_id INT64,
  object_type STRING NOT NULL,
  host_facility STRING NOT NULL,
  host_type STRING NOT NULL,
  host STRING NOT NULL,
  service STRING,
  host_plaza STRING NOT NULL,
  plaza_latitude BIGNUMERIC(50, 12),
  plaza_longitude BIGNUMERIC(50, 12),
  is_active INT64 NOT NULL,
  is_deleted INT64,
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME NOT NULL
)
cluster by nagios_object_id
;
