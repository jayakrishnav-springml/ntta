-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_contactnotificationmethods.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_ContactNotificationMethods
(
  contactnotificationmethod_id INT64,
  instance_id INT64,
  contactnotification_id INT64,
  start_time DATETIME,
  start_time_usec INT64,
  end_time DATETIME,
  end_time_usec INT64,
  command_object_id INT64,
  command_args STRING,
  lnd_updatedate DATETIME NOT NULL
)
;
