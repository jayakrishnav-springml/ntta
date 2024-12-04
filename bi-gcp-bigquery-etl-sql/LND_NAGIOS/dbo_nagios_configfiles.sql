-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_nagios_configfiles.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_ConfigFiles
(
  configfile_id INT64,
  instance_id INT64,
  configfile_type INT64,
  configfile_path STRING,
  lnd_updatedate DATETIME NOT NULL
)
;
