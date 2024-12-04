-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_AP_USERS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Ap_Users
(
  ap_user_id INT64 NOT NULL,
  display_name STRING NOT NULL,
  user_name STRING NOT NULL,
  employee_number NUMERIC(29),
  password STRING,
  date_created DATETIME NOT NULL,
  modified_by STRING,
  date_modified DATETIME,
  created_by STRING NOT NULL,
  email_address STRING,
  restricted STRING NOT NULL,
  working_pos_id INT64,
  last_login_date DATETIME,
  user_session_id STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
