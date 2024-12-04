-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_programstatus.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_ProgramStatus
(
  programstatus_id INT64,
  instance_id INT64,
  status_update_time DATETIME,
  program_start_time DATETIME,
  program_end_time DATETIME,
  is_currently_running INT64,
  process_id INT64,
  daemon_mode INT64,
  last_command_check DATETIME,
  last_log_rotation DATETIME,
  notifications_enabled INT64,
  active_service_checks_enabled INT64,
  passive_service_checks_enabled INT64,
  active_host_checks_enabled INT64,
  passive_host_checks_enabled INT64,
  event_handlers_enabled INT64,
  flap_detection_enabled INT64,
  failure_prediction_enabled INT64,
  process_performance_data INT64,
  obsess_over_hosts INT64,
  obsess_over_services INT64,
  modified_host_attributes INT64,
  modified_service_attributes INT64,
  global_host_event_handler STRING,
  global_service_event_handler STRING,
  lnd_updatedate DATETIME NOT NULL
)
;
