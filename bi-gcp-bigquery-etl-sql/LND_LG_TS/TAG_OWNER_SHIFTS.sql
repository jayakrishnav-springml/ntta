-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_SHIFTS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Shifts
(
  shift_id INT64 NOT NULL,
  shift_start DATETIME,
  shift_end DATETIME,
  ap_user_id INT64,
  pos_id INT64,
  cash_opn_bal NUMERIC(31, 2),
  cash_cls_bal NUMERIC(31, 2),
  cash_adj_amt NUMERIC(31, 2),
  chk_mo_adj_amt NUMERIC(31, 2),
  cc_adj_amt NUMERIC(31, 2),
  chk_cls_bal NUMERIC(31, 2),
  cc_cls_bal NUMERIC(31, 2),
  phone_calls INT64,
  walk_in_customers INT64,
  toll_tag_updates INT64,
  adj_rsn STRING,
  deposit_status STRING,
  bank_deposit_id INT64,
  shift_status STRING,
  deposit_date DATETIME,
  created_by STRING,
  attribute_1 STRING,
  date_created DATETIME,
  modified_by STRING,
  date_modified DATETIME,
  deposit_business_date DATETIME,
  last_update_type STRING,
  last_update_date DATETIME
)
;
