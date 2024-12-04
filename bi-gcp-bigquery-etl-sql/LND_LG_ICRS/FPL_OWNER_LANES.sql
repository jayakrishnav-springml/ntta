-- Translation time: 2024-06-04T07:59:17.388387Z
-- Translation job ID: 5118bff3-1545-4bd3-96b6-65be13aded87
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_ICRS/Tables/FPL_OWNER_LANES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_ICRS.Fpl_Owner_Lanes
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
  old_location_id INT64,
  lane_cust_descr STRING,
  lc_lane_nbr INT64,
  lc_plaza_nbr INT64,
  is_interop STRING,
  lany_id NUMERIC(29) NOT NULL,
  plgr_id INT64,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
CLUSTER BY lane_id
;
