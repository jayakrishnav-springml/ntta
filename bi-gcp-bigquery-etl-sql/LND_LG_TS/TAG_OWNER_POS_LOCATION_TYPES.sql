-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_POS_LOCATION_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Pos_Location_Types
(
  pos_type STRING NOT NULL,
  pos_loc_type_descr STRING NOT NULL,
  active_flag STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
