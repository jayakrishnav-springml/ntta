-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_Service_Event.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Service_Event
(
  service_event_id INT64 NOT NULL,
  service_object_id INT64 NOT NULL,
  event_date DATETIME NOT NULL,
  service_state INT64 NOT NULL,
  host STRING NOT NULL,
  service STRING NOT NULL,
  event_info STRING,
  perf_data STRING,
  metric_string STRING,
  metric_count INT64,
  lnd_updatedate DATETIME
)
cluster by service_event_id
;

/*alter for CDC changes*/

ALTER TABLE LND_NAGIOS.Service_Event  ADD COLUMN IF NOT EXISTS lnd_updatetype STRING, ADD COLUMN IF NOT EXISTS src_changedate DATETIME;
