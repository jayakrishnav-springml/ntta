-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VPS_VARIANCE_IMG_DISCARDS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vps_Variance_Img_Discards
(
  viol_date DATETIME NOT NULL,
  viol_reject_type STRING NOT NULL,
  lane_id NUMERIC(29) NOT NULL,
  img_discard_cnt FLOAT64,
  revenue NUMERIC(33, 4),
  date_created DATETIME,
  business_type STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;