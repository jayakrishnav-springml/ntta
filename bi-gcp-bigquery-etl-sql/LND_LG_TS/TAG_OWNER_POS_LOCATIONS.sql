-- Translation time: 2024-06-04T08:03:02.538216Z
-- Translation job ID: 2ee163b6-d1ed-4585-9295-ffd9f05ba970
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_TS/Tables/TAG_OWNER_POS_LOCATIONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_TS.Tag_Owner_Pos_Locations
(
  pos_id INT64 NOT NULL,
  pos_name STRING NOT NULL,
  pos_type STRING NOT NULL,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING NOT NULL,
  zip_code STRING,
  plus4 STRING,
  phone_nbr STRING,
  fax_nbr STRING,
  pos_manager STRING,
  is_active STRING,
  art_id INT64,
  online_pos_id INT64,
  authorization_store_number INT64,
  phone_ext STRING,
  manager STRING,
  tag_threshold INT64,
  merchant_name STRING,
  date_modified DATETIME,
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  tp STRING,
  last_update_type STRING,
  last_update_date DATETIME
)
;
