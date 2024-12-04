-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_BANK_DEPOSITS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Bank_Deposits
(
  bank_deposit_id INT64 NOT NULL,
  bank_account_id NUMERIC(29) NOT NULL,
  txn_date DATETIME,
  txn_amount NUMERIC(31, 2),
  cash_amount NUMERIC(31, 2),
  check_amount NUMERIC(31, 2),
  money_order_amount NUMERIC(31, 2),
  other_amount NUMERIC(31, 2),
  ap_user_id INT64 NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING,
  date_modified DATETIME,
  comments STRING,
  comment_date DATETIME,
  vpc_loc_id INT64 NOT NULL,
  pos_id INT64 NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
