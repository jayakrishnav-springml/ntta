-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_CA_ACCTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Ca_Accts
(
  ca_acct_id NUMERIC(29) NOT NULL,
  ca_company_id INT64,
  ca_acct_date DATETIME NOT NULL,
  violator_id NUMERIC(29) NOT NULL,
  ca_acct_status STRING NOT NULL,
  ca_acct_batch_id INT64,
  mail_date DATETIME,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  modified_by STRING,
  date_modified DATETIME,
  status_date DATETIME,
  status_modified_by STRING,
  file_generated STRING,
  file_gen_date DATETIME,
  file_name STRING,
  payment_file_generated STRING,
  payment_file_gen_date DATETIME,
  payment_file_name STRING,
  undo_file_generated STRING,
  undo_file_gen_date DATETIME,
  undo_file_name STRING,
  account_toll NUMERIC(33, 4) NOT NULL,
  account_fine NUMERIC(33, 4) NOT NULL,
  account_close_date DATETIME,
  parent_ca_acct_id NUMERIC(29),
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
