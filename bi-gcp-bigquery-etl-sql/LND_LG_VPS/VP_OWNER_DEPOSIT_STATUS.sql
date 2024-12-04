-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_DEPOSIT_STATUS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Deposit_Status
(
  deposit_status STRING NOT NULL,
  deposit_status_descr STRING NOT NULL,
  is_active STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
