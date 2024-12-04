-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_timeperiod_timeranges.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_Timeperiod_Timeranges
(
  timeperiod_timerange_id INT64,
  instance_id INT64,
  timeperiod_id INT64,
  day INT64,
  start_sec INT64,
  end_sec INT64,
  lnd_updatedate DATETIME NOT NULL
)
;
