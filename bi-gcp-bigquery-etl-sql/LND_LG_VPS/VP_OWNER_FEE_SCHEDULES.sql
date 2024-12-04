-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_FEE_SCHEDULES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Fee_Schedules
(
  fee_id NUMERIC(29) NOT NULL,
  fee_type_code STRING NOT NULL,
  from_num_days NUMERIC(29),
  to_num_days NUMERIC(29),
  fee_amt NUMERIC(33, 4),
  date_created DATETIME,
  created_by STRING,
  date_modified DATETIME,
  modified_by STRING,
  invoice_start_date DATETIME NOT NULL,
  invoice_end_date DATETIME,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by fee_id
;
