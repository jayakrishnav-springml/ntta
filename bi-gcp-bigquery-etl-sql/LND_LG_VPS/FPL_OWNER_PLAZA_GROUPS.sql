-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/FPL_OWNER_PLAZA_GROUPS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Fpl_Owner_Plaza_Groups
(
  agcy_agcy_id NUMERIC(29) NOT NULL,
  plgp_id INT64 NOT NULL,
  plgp_desc STRING,
  lc_plaza_nbr INT64,
  descr STRING,
  location_code STRING,
  user_code STRING,
  has_lanes STRING NOT NULL,
  has_deposits STRING NOT NULL,
  abbrev STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
