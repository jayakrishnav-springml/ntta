-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_downtimehistory.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_DownTimeHistory
(
  downtimehistory_id INT64,
  instance_id INT64,
  downtime_type INT64,
  object_id INT64,
  entry_time DATETIME,
  author_name STRING,
  comment_data STRING,
  internal_downtime_id INT64,
  triggered_by_id INT64,
  is_fixed INT64,
  duration INT64,
  scheduled_start_time DATETIME,
  scheduled_end_time DATETIME,
  was_started INT64,
  actual_start_time DATETIME,
  actual_start_time_usec INT64,
  actual_end_time DATETIME,
  actual_end_time_usec INT64,
  was_cancelled INT64,
  lnd_updatedate DATETIME NOT NULL
)
;
