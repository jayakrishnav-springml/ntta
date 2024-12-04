-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_hostescalations.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_HostEscalations
(
  hostescalation_id INT64,
  instance_id INT64,
  config_type INT64,
  host_object_id INT64,
  timeperiod_object_id INT64,
  first_notification INT64,
  last_notification INT64,
  notification_interval FLOAT64,
  escalate_on_recovery INT64,
  escalate_on_down INT64,
  escalate_on_unreachable INT64,
  lnd_updatedate DATETIME NOT NULL
)
;