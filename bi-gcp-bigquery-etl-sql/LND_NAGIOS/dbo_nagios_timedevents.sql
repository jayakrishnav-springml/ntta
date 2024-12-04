-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_timedevents.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_TimedEvents
(
  timedevent_id INT64,
  instance_id INT64,
  event_type INT64,
  queued_time DATETIME,
  queued_time_usec INT64,
  event_time DATETIME,
  event_time_usec INT64,
  scheduled_time DATETIME,
  recurring_event INT64,
  object_id INT64,
  deletion_time DATETIME,
  deletion_time_usec INT64,
  lnd_updatedate DATETIME NOT NULL
)
;
