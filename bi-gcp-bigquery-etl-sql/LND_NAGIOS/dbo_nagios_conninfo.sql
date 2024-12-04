-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_conninfo.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_ConnInfo
(
  conninfo_id INT64,
  instance_id INT64,
  agent_name STRING,
  agent_version STRING,
  disposition STRING,
  connect_source STRING,
  connect_type STRING,
  connect_time DATETIME,
  disconnect_time DATETIME,
  last_checkin_time DATETIME,
  data_start_time DATETIME,
  data_end_time DATETIME,
  bytes_processed INT64,
  lines_processed INT64,
  entries_processed INT64,
  lnd_updatedate DATETIME NOT NULL
)
;
