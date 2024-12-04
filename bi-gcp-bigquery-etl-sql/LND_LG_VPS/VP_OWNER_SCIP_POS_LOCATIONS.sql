-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_SCIP_POS_LOCATIONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Scip_Pos_Locations
(
  pos_id INT64 NOT NULL,
  scip_pos_id INT64 NOT NULL,
  date_created DATETIME,
  date_modified DATETIME,
  modified_by STRING,
  created_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;