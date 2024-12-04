-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_VPS_VLTR_MATCHES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Vps_Vltr_Matches
(
  vps_vltrmtch_id BIGNUMERIC(48, 10) NOT NULL,
  docno STRING,
  drec_id NUMERIC(29) NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  violator_id NUMERIC(29),
  ownr_id NUMERIC(29),
  vehi_id NUMERIC(29),
  process_flag STRING NOT NULL,
  created_date DATETIME NOT NULL,
  modified_date DATETIME,
  unprocess_reason STRING,
  record_type STRING,
  first_name STRING,
  last_name STRING,
  owner_begin_date DATETIME,
  owner_end_date DATETIME,
  make_abbrev STRING,
  model_abbrev STRING,
  vehicle_year STRING,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING,
  zip_code STRING,
  plus4 STRING,
  vltrnotindmvid BIGNUMERIC(48, 10),
  last_update_date DATETIME,
  last_update_type STRING
)
;
