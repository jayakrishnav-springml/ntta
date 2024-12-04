-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_services_STAGE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS_STAGE_CDC.Nagios_Services
(
  service_id INT64,
  instance_id INT64,
  config_type INT64,
  host_object_id INT64,
  service_object_id INT64,
  display_name STRING,
  importance INT64,
  check_command_object_id INT64,
  check_command_args STRING,
  eventhandler_command_object_id INT64,
  eventhandler_command_args STRING,
  notification_timeperiod_object_id INT64,
  check_timeperiod_object_id INT64,
  failure_prediction_options STRING,
  check_interval FLOAT64,
  retry_interval FLOAT64,
  max_check_attempts INT64,
  first_notification_delay FLOAT64,
  notification_interval FLOAT64,
  notify_on_warning INT64,
  notify_on_unknown INT64,
  notify_on_critical INT64,
  notify_on_recovery INT64,
  notify_on_flapping INT64,
  notify_on_downtime INT64,
  stalk_on_ok INT64,
  stalk_on_warning INT64,
  stalk_on_unknown INT64,
  stalk_on_critical INT64,
  is_volatile INT64,
  flap_detection_enabled INT64,
  flap_detection_on_ok INT64,
  flap_detection_on_warning INT64,
  flap_detection_on_unknown INT64,
  flap_detection_on_critical INT64,
  low_flap_threshold FLOAT64,
  high_flap_threshold FLOAT64,
  process_performance_data INT64,
  freshness_checks_enabled INT64,
  freshness_threshold INT64 NOT NULL,
  passive_checks_enabled INT64,
  event_handler_enabled INT64,
  active_checks_enabled INT64,
  retain_status_information INT64,
  retain_nonstatus_information INT64,
  notifications_enabled INT64,
  obsess_over_service INT64,
  failure_prediction_enabled INT64,
  notes STRING,
  notes_url STRING,
  action_url STRING,
  icon_image STRING,
  icon_image_alt STRING,
  lnd_updatedate DATETIME NOT NULL
)
;

/*alter for CDC changes*/

ALTER TABLE LND_NAGIOS_STAGE_CDC.Nagios_Services ADD COLUMN IF NOT EXISTS lnd_updatetype STRING, ADD COLUMN IF NOT EXISTS src_changedate DATETIME;