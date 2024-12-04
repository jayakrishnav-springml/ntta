-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_PAYMENT_SOURCE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Payment_Source
(
  payment_source_code STRING NOT NULL,
  payment_source_code_descr STRING NOT NULL,
  payment_source_code_order INT64,
  is_active STRING NOT NULL,
  vb_payment_source_code_descr STRING NOT NULL,
  last_update_date DATETIME NOT NULL,
  last_update_type STRING NOT NULL
)
;