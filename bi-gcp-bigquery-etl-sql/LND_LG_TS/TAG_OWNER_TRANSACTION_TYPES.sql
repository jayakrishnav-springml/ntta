-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_TRANSACTION_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Transaction_Types
(
  trans_type_id NUMERIC(29),
  access_level INT64,
  trans_type_descr STRING,
  trans_type_long_descr STRING,
  trans_type_order INT64,
  default_value_flag STRING,
  active_flag STRING,
  manual_entry_flag STRING,
  statement_flag STRING,
  receipt_flag STRING,
  balance_multiplier INT64,
  deposit_multiplier INT64,
  acct_status STRING,
  tag_status STRING,
  payment_due STRING,
  editable STRING,
  delete_flag STRING,
  tct_id NUMERIC(29),
  pmt_type_code STRING,
  lic_plate_tag STRING,
  acct_type_code STRING,
  last_update_type STRING,
  last_update_date DATETIME
)
;
