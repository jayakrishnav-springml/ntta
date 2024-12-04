-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_POS_LOCATION_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Pos_Location_Types
(
  pos_type STRING NOT NULL,
  pos_loc_type_descr STRING NOT NULL,
  active_flag STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
