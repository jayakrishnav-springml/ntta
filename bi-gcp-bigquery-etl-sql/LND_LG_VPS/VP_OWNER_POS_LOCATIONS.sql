-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_POS_LOCATIONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Pos_Locations
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
  phone_ext STRING,
  fax_nbr STRING,
  manager STRING,
  tag_threshold INT64,
  is_active STRING NOT NULL,
  art_id INT64 NOT NULL,
  pos_manager STRING,
  online_pos_id INT64,
  authorization_store_number INT64,
  merchant_name STRING,
  date_modified DATETIME,
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
CLUSTER BY pos_id
;
