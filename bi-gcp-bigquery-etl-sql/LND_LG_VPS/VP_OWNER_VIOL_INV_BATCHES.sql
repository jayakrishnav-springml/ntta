-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_VIOL_INV_BATCHES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Viol_Inv_Batches
(
  viol_inv_batch_id NUMERIC(29) NOT NULL,
  date_produced DATETIME NOT NULL,
  date_printed DATETIME,
  date_mailed DATETIME,
  invoice_count INT64 NOT NULL,
  min_nbr_viol INT64,
  days_interval INT64,
  date_back_to DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
