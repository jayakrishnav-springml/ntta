-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/IOP_OWNER_HUB_LVL_PLATE_DETAILS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Iop_Owner_Hub_Lvl_Plate_Details
(
  hub_lvl_plate_dtls_id NUMERIC(29) NOT NULL,
  lvl_from_agcy_id NUMERIC(29) NOT NULL,
  lvl_to_agcy_id NUMERIC(29) NOT NULL,
  batch_mode STRING NOT NULL,
  tag_identifier STRING,
  tag_id STRING,
  lvl_plate_status STRING NOT NULL,
  vehicle_class_code INT64 NOT NULL,
  rev_type INT64 NOT NULL,
  lic_plate_state STRING NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  alt_lic_plate_nbr STRING,
  alt_lic_plate_state STRING,
  date_lvl_effective DATETIME NOT NULL,
  date_lvl_expired DATETIME,
  lic_plate_effective_date DATETIME,
  lic_plate_expiration_date DATETIME,
  attribute_3 STRING,
  lvl_home_authority STRING,
  home_authority_account_id STRING,
  lic_plate_type STRING,
  first_lvl_batch_id NUMERIC(29) NOT NULL,
  last_full_lvl_batch_id NUMERIC(29),
  last_inc_lvl_batch_id NUMERIC(29),
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
