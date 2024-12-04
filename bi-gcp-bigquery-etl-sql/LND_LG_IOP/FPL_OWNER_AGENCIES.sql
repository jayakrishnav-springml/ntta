-- Translation time: 2024-06-04T08:01:15.437249Z
-- Translation job ID: a14a1a7f-7d63-47c9-8296-0b7483d5c271
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_IOP/Tables/FPL_OWNER_AGENCIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_IOP.Fpl_Owner_Agencies
(
  abbrev STRING NOT NULL,
  name STRING NOT NULL,
  note STRING,
  created_by STRING NOT NULL,
  creation_date DATETIME NOT NULL,
  updated_by STRING NOT NULL,
  updated_date DATETIME NOT NULL,
  agcy_id NUMERIC(29) NOT NULL,
  tag_identifier STRING,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING NOT NULL,
  zip_code STRING,
  plus4 STRING,
  contact_info STRING,
  help_desk_email STRING,
  web_address STRING,
  home_agency_flag STRING,
  is_iop STRING NOT NULL,
  eft_automated STRING NOT NULL,
  hub_id STRING,
  iop_agency_id STRING,
  send_to_lanes STRING,
  agency_type STRING,
  is_active STRING,
  cusiop_home_agency_flag STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
