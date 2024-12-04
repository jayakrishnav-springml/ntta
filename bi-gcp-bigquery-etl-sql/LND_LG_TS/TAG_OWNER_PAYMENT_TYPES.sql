-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_PAYMENT_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Payment_Types
(
  pt_type_id INT64 NOT NULL,
  pt_descr STRING NOT NULL,
  pt_long_descr STRING,
  active_flag STRING NOT NULL,
  editable STRING NOT NULL,
  manual_entry_flag STRING NOT NULL,
  payment_multiplier INT64 NOT NULL,
  pt_type_order INT64,
  default_value_flag STRING NOT NULL,
  icv_code STRING,
  pct_id INT64 NOT NULL,
  last_update_type STRING,
  last_update_date DATETIME
)
;
