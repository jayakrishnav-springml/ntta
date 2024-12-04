-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_notifications.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_Notifications
(
  notification_id INT64,
  instance_id INT64,
  notification_type INT64,
  notification_reason INT64,
  object_id INT64,
  start_time DATETIME,
  start_time_usec INT64,
  end_time DATETIME,
  end_time_usec INT64,
  state INT64,
  output STRING,
  long_output STRING,
  escalated INT64,
  contacts_notified INT64,
  lnd_updatedate DATETIME NOT NULL
)
;
