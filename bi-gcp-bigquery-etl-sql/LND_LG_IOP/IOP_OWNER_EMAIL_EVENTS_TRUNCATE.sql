-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_EMAIL_EVENTS_TRUNCATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Email_Events_Truncate
(
  email_event_id NUMERIC(29) NOT NULL,
  event_name STRING NOT NULL,
  last_executed DATETIME,
  function_name STRING,
  active STRING,
  subject STRING NOT NULL,
  default_from STRING NOT NULL,
  default_to STRING,
  default_cc STRING,
  default_bcc STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
