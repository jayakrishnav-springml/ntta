-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_EMAIL_SEND_LOG.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Email_Send_Log
(
  email_log_id NUMERIC(29) NOT NULL,
  subject STRING NOT NULL,
  sent_from STRING,
  sent_to STRING,
  sent_cc STRING,
  sent_bcc STRING,
  send_successful STRING,
  resend_email_log_id NUMERIC(29),
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
