-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_Host_Event.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Host_Event
(
  host_event_id INT64 NOT NULL,
  host_object_id INT64 NOT NULL,
  event_date DATETIME NOT NULL,
  host_state INT64 NOT NULL,
  host STRING,
  event_info STRING,
  perf_data STRING,
  metric_string STRING,
  metric_count INT64,
  lnd_updatedate DATETIME
)
cluster by host_event_id
;

/*alter for CDC changes*/

ALTER TABLE LND_NAGIOS.Host_Event  ADD COLUMN IF NOT EXISTS lnd_updatetype STRING, ADD COLUMN IF NOT EXISTS src_changedate DATETIME;
