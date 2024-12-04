-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_contactstatus.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_ContactStatus
(
  contactstatus_id INT64,
  instance_id INT64,
  contact_object_id INT64,
  status_update_time DATETIME,
  host_notifications_enabled INT64,
  service_notifications_enabled INT64,
  last_host_notification DATETIME,
  last_service_notification DATETIME,
  modified_attributes INT64,
  modified_host_attributes INT64,
  modified_service_attributes INT64,
  lnd_updatedate DATETIME NOT NULL
)
;
