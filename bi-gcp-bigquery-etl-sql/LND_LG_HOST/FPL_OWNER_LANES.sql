-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/FPL_OWNER_LANES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Fpl_Owner_Lanes
(
  name STRING NOT NULL,
  note STRING,
  mileage NUMERIC(31, 2),
  created_by STRING NOT NULL,
  creation_date DATETIME NOT NULL,
  updated_by STRING NOT NULL,
  updated_date DATETIME NOT NULL,
  lane_id NUMERIC(29) NOT NULL,
  plaz_id NUMERIC(29) NOT NULL,
  dire_id NUMERIC(29) NOT NULL,
  abbrev STRING,
  old_lane_nbr STRING,
  old_lane_abbrev STRING,
  old_location_id NUMERIC(29),
  lane_cust_descr STRING,
  lc_lane_nbr NUMERIC(29),
  lc_plaza_nbr NUMERIC(29),
  is_interop STRING,
  lany_id NUMERIC(29) NOT NULL,
  plgr_id NUMERIC(29),
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by lane_id
;
