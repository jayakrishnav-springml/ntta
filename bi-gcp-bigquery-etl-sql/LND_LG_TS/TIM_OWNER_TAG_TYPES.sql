-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TIM_OWNER_TAG_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tim_Owner_Tag_Types
(
  tag_type STRING NOT NULL,
  tag_type_descr STRING,
  tag_type_order INT64,
  default_value_flag STRING NOT NULL,
  active_flag STRING NOT NULL,
  last_update_type STRING,
  last_update_date DATETIME
)
;
