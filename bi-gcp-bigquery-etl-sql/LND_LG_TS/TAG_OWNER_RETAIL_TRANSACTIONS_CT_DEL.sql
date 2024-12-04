-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_RETAIL_TRANSACTIONS_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Retail_Transactions_Ct_Del
(
  retail_trans_id INT64,
  trans_amt NUMERIC(31, 2),
  trans_date DATETIME,
  posted_date DATETIME,
  trans_status STRING,
  beginning_balance NUMERIC(31, 2),
  beginning_deposit NUMERIC(31, 2),
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  acct_id NUMERIC(29),
  pos_id INT64,
  ap_user_id INT64,
  due_amt NUMERIC(31, 2),
  tendered_amt NUMERIC(31, 2),
  change_due_amt NUMERIC(31, 2),
  ol_pmt_id NUMERIC(29),
  ttxn_id NUMERIC(29),
  insert_datetime DATETIME NOT NULL
)
;
