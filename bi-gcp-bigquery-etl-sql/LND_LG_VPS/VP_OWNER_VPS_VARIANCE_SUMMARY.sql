-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VPS_VARIANCE_SUMMARY.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vps_Variance_Summary
(
  txn_date DATETIME,
  txn_name STRING,
  lane_id NUMERIC(29),
  cnt INT64,
  revenue NUMERIC(31, 2),
  date_created DATETIME,
  business_type STRING,
  last_update_type STRING,
  last_update_date DATETIME
)
;
