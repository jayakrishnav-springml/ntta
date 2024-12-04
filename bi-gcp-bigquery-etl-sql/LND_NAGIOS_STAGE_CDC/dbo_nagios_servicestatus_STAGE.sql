-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_servicestatus_STAGE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS_STAGE_CDC.Nagios_ServiceStatus
(
  servicestatus_id INT64,
  instance_id INT64,
  service_object_id INT64,
  status_update_time DATETIME,
  output STRING,
  long_output STRING,
  perfdata STRING,
  current_state INT64,
  has_been_checked INT64,
  should_be_scheduled INT64,
  current_check_attempt INT64,
  max_check_attempts INT64,
  last_check DATETIME,
  next_check DATETIME,
  check_type INT64,
  last_state_change DATETIME,
  last_hard_state_change DATETIME,
  last_hard_state INT64,
  last_time_ok DATETIME,
  last_time_warning DATETIME,
  last_time_unknown DATETIME,
  last_time_critical DATETIME,
  state_type INT64,
  last_notification DATETIME,
  next_notification DATETIME,
  no_more_notifications INT64,
  notifications_enabled INT64,
  problem_has_been_acknowledged INT64,
  acknowledgement_type INT64,
  current_notification_number INT64,
  passive_checks_enabled INT64,
  active_checks_enabled INT64,
  event_handler_enabled INT64,
  flap_detection_enabled INT64,
  is_flapping INT64,
  percent_state_change FLOAT64,
  latency FLOAT64,
  execution_time FLOAT64,
  scheduled_downtime_depth INT64,
  failure_prediction_enabled INT64,
  process_performance_data INT64,
  obsess_over_service INT64,
  modified_service_attributes INT64,
  event_handler STRING,
  check_command STRING,
  normal_check_interval FLOAT64,
  retry_check_interval FLOAT64,
  check_timeperiod_object_id INT64,
  lnd_updatedate DATETIME
)
;

/*alter for CDC changes*/

ALTER TABLE LND_NAGIOS_STAGE_CDC.Nagios_ServiceStatus ADD COLUMN IF NOT EXISTS lnd_updatetype STRING, ADD COLUMN IF NOT EXISTS src_changedate DATETIME;

