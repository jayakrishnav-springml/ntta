-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TIM_OWNER_LOCATIONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tim_Owner_Locations
(
  location_id INT64 NOT NULL,
  location_name STRING NOT NULL,
  address1 STRING,
  address2 STRING,
  city STRING,
  zip_code INT64,
  plus4 INT64,
  phone_nbr STRING,
  phone_ext STRING,
  fax_nbr STRING,
  active_flag STRING NOT NULL,
  location_type STRING NOT NULL,
  state_code STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
