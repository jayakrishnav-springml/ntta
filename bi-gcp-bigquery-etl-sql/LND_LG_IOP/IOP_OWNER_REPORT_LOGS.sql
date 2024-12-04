-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_REPORT_LOGS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Report_Logs
(
  log_id INT64 NOT NULL,
  event_id INT64 NOT NULL,
  param_id INT64,
  report_name STRING NOT NULL,
  format STRING,
  des_type STRING,
  des_name STRING,
  started_at DATETIME,
  finished_at DATETIME,
  date_created DATETIME NOT NULL,
  date_modified DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  created_by STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
