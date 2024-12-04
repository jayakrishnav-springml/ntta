-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/FPL_OWNER_LANES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Fpl_Owner_Lanes
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
