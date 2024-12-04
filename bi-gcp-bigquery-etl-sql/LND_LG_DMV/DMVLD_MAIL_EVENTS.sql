-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_MAIL_EVENTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Mail_Events
(
  mail_event_id INT64 NOT NULL,
  event_name STRING,
  event_type STRING,
  frequency STRING,
  last_executed DATETIME,
  function_name STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  active STRING,
  mail_format STRING,
  default_from STRING,
  default_to STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
