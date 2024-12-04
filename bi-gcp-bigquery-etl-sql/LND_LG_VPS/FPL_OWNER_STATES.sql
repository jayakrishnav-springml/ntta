-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/FPL_OWNER_STATES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Fpl_Owner_States
(
  state_code STRING NOT NULL,
  state_name STRING,
  country_code STRING,
  state_order INT64,
  default_value_flag STRING,
  iop_country_code STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
