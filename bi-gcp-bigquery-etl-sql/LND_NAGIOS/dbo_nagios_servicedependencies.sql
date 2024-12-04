-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_servicedependencies.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_ServiceDependencies
(
  servicedependency_id INT64,
  instance_id INT64,
  config_type INT64,
  service_object_id INT64,
  dependent_service_object_id INT64,
  dependency_type INT64,
  inherits_parent INT64,
  timeperiod_object_id INT64,
  fail_on_ok INT64,
  fail_on_warning INT64,
  fail_on_unknown INT64,
  fail_on_critical INT64,
  lnd_updatedate DATETIME NOT NULL
)
;