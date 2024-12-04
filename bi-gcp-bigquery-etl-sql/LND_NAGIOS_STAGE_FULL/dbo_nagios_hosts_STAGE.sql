-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_hosts_STAGE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS_STAGE_FULL.Nagios_Hosts
(
  host_id INT64 NOT NULL,
  instance_id INT64 NOT NULL,
  config_type INT64 NOT NULL,
  host_object_id INT64 NOT NULL,
  alias STRING,
  display_name STRING,
  address STRING NOT NULL,
  importance INT64 NOT NULL,
  check_command_object_id INT64 NOT NULL,
  check_command_args STRING,
  eventhandler_command_object_id INT64 NOT NULL,
  eventhandler_command_args STRING,
  notification_timeperiod_object_id INT64 NOT NULL,
  check_timeperiod_object_id INT64 NOT NULL,
  failure_prediction_options STRING NOT NULL,
  check_interval FLOAT64 NOT NULL,
  retry_interval FLOAT64 NOT NULL,
  max_check_attempts INT64 NOT NULL,
  first_notification_delay FLOAT64 NOT NULL,
  notification_interval FLOAT64 NOT NULL,
  notify_on_down INT64 NOT NULL,
  notify_on_unreachable INT64 NOT NULL,
  notify_on_recovery INT64 NOT NULL,
  notify_on_flapping INT64 NOT NULL,
  notify_on_downtime INT64 NOT NULL,
  stalk_on_up INT64 NOT NULL,
  stalk_on_down INT64 NOT NULL,
  stalk_on_unreachable INT64 NOT NULL,
  flap_detection_enabled INT64 NOT NULL,
  flap_detection_on_up INT64 NOT NULL,
  flap_detection_on_down INT64 NOT NULL,
  flap_detection_on_unreachable INT64 NOT NULL,
  low_flap_threshold FLOAT64 NOT NULL,
  high_flap_threshold FLOAT64 NOT NULL,
  process_performance_data INT64 NOT NULL,
  freshness_checks_enabled INT64 NOT NULL,
  freshness_threshold INT64 NOT NULL,
  passive_checks_enabled INT64 NOT NULL,
  event_handler_enabled INT64 NOT NULL,
  active_checks_enabled INT64 NOT NULL,
  retain_status_information INT64 NOT NULL,
  retain_nonstatus_information INT64 NOT NULL,
  notifications_enabled INT64 NOT NULL,
  obsess_over_host INT64 NOT NULL,
  failure_prediction_enabled INT64 NOT NULL,
  notes STRING NOT NULL,
  notes_url STRING NOT NULL,
  action_url STRING NOT NULL,
  icon_image STRING NOT NULL,
  icon_image_alt STRING NOT NULL,
  vrml_image STRING NOT NULL,
  statusmap_image STRING NOT NULL,
  have_2d_coords INT64 NOT NULL,
  x_2d INT64 NOT NULL,
  y_2d INT64 NOT NULL,
  have_3d_coords INT64 NOT NULL,
  x_3d FLOAT64 NOT NULL,
  y_3d FLOAT64 NOT NULL,
  z_3d FLOAT64 NOT NULL,
  lnd_updatedate DATETIME NOT NULL
)
;

/*alter for CDC changes*/

ALTER TABLE LND_NAGIOS_STAGE_FULL.Nagios_Hosts ADD COLUMN IF NOT EXISTS lnd_updatetype STRING, ADD COLUMN IF NOT EXISTS src_changedate DATETIME;

