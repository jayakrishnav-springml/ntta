-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_statehistory.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_StateHistory
(
  statehistory_id INT64,
  instance_id INT64,
  state_time DATETIME,
  state_time_usec INT64,
  object_id INT64,
  state_change INT64,
  state INT64,
  state_type INT64,
  current_check_attempt INT64,
  max_check_attempts INT64,
  last_state INT64,
  last_hard_state INT64,
  output STRING,
  long_output STRING,
  lnd_updatedate DATETIME NOT NULL
)
;
