-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_servicechecks.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_ServiceChecks
(
  instance_id INT64,
  service_object_id INT64,
  check_type INT64,
  current_check_attempt INT64,
  max_check_attempts INT64,
  state INT64,
  state_type INT64,
  start_time DATETIME,
  start_time_usec INT64,
  end_time DATETIME,
  end_time_usec INT64,
  command_object_id INT64,
  command_args STRING,
  command_line STRING,
  timeout INT64,
  early_timeout INT64,
  execution_time FLOAT64,
  latency FLOAT64,
  return_code INT64,
  output STRING,
  long_output STRING,
  perfdata STRING,
  servicecheck_id STRING,
  lnd_updatedate DATETIME NOT NULL
)
;
