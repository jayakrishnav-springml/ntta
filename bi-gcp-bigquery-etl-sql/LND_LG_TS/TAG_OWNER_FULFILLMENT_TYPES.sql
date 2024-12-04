-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_FULFILLMENT_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Fulfillment_Types
(
  fulfillment_type_code STRING NOT NULL,
  fulfillment_type_descr STRING NOT NULL,
  fulfillment_type_long_descr STRING,
  active_flag STRING NOT NULL,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;