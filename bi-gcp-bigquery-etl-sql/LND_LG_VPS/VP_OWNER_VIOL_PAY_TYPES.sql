-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VIOL_PAY_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Viol_Pay_Types
(
  viol_pay_type STRING NOT NULL,
  viol_pay_type_descr STRING NOT NULL,
  viol_pay_type_order INT64,
  is_active STRING NOT NULL,
  last_update_date DATETIME NOT NULL,
  last_update_type STRING NOT NULL
)
;
