-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_contacts.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_Contacts
(
  contact_id INT64,
  instance_id INT64,
  config_type INT64,
  contact_object_id INT64,
  alias STRING,
  email_address STRING,
  pager_address STRING,
  minimum_importance INT64,
  host_timeperiod_object_id INT64,
  service_timeperiod_object_id INT64,
  host_notifications_enabled INT64,
  service_notifications_enabled INT64,
  can_submit_commands INT64,
  notify_service_recovery INT64,
  notify_service_warning INT64,
  notify_service_unknown INT64,
  notify_service_critical INT64,
  notify_service_flapping INT64,
  notify_service_downtime INT64,
  notify_host_recovery INT64,
  notify_host_down INT64,
  notify_host_unreachable INT64,
  notify_host_flapping INT64,
  notify_host_downtime INT64,
  lnd_updatedate DATETIME NOT NULL
)
;
