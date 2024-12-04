-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VIOL_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Viol_Types
(
  viol_type STRING NOT NULL,
  viol_type_descr STRING NOT NULL,
  viol_type_order INT64 NOT NULL,
  is_active STRING NOT NULL,
  last_update_type STRING,
  last_update_date DATETIME
)
;
