-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_IOP_REASON_CODES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Iop_Reason_Codes
(
  reason_code STRING NOT NULL,
  reason_code_descr STRING,
  is_active STRING NOT NULL,
  order_by INT64,
  created_by STRING NOT NULL,
  created_date DATETIME NOT NULL,
  modified_by STRING,
  modified_date DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;