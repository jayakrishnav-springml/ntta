-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VPS_VARIANCE_TXNS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Vps_Variance_Txns
(
  txn_id FLOAT64 NOT NULL,
  txn_name STRING NOT NULL,
  txn_desc STRING,
  parent_id FLOAT64,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
