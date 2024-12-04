-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/dbo_Nagios_acknowledgements.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS.Nagios_Acknowledgements
(
  acknowledgement_id INT64,
  instance_id INT64,
  entry_time DATETIME,
  entry_time_usec INT64,
  acknowledgement_type INT64,
  object_id INT64,
  state INT64,
  author_name STRING,
  comment_data STRING,
  is_sticky INT64,
  persistent_comment INT64,
  notify_contacts INT64,
  lnd_updatedate DATETIME NOT NULL
)
;
