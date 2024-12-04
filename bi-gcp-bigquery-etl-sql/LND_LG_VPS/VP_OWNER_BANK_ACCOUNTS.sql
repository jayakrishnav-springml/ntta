-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_BANK_ACCOUNTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Bank_Accounts
(
  bank_account_id INT64 NOT NULL,
  bank_account_desc STRING NOT NULL,
  account_number STRING NOT NULL,
  bnk_branch_id INT64 NOT NULL,
  comments STRING,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING,
  date_modified DATETIME,
  is_active STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;