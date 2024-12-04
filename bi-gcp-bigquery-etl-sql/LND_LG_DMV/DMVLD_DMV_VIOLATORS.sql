-- Translation time: 2024-05-22T12:36:41.830310Z
-- Translation job ID: d3568ee0-99d8-46a7-93e2-5d48994c87d3
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_DMV/Tables/DMVLD_DMV_VIOLATORS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_DMV.Dmvld_Dmv_Violators
(
  violator_id NUMERIC(29) NOT NULL,
  violator_fname STRING,
  violator_lname STRING,
  violator_fname2 STRING,
  violator_lname2 STRING,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  phone_nbr STRING,
  email_addr STRING,
  driver_lic_nbr STRING,
  driver_lic_state STRING,
  spanish_only STRING NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING,
  date_modified DATETIME,
  usage_begin_date DATETIME,
  usage_end_date DATETIME,
  violator_comment STRING,
  comment_date DATETIME,
  violator_type STRING NOT NULL,
  race STRING,
  gender STRING,
  dob DATETIME,
  bounce_count INT64 NOT NULL,
  violation_count INT64 NOT NULL,
  excusal_count INT64 NOT NULL,
  no_dl_last_date DATETIME,
  no_dl_resubmits INT64,
  discounted_by STRING,
  discounted_date DATETIME,
  is_discounted STRING,
  is_vea STRING,
  vehicle_make STRING,
  vehicle_model STRING,
  vehicle_body STRING,
  vehicle_year STRING,
  vehicle_color STRING,
  dps_violator_name INT64 NOT NULL,
  docno STRING,
  ownr_id NUMERIC(29),
  vehi_id NUMERIC(29),
  contract_id STRING,
  fleet_file_id NUMERIC(29),
  vin STRING,
  violator_source STRING NOT NULL,
  vltr_creation_reason STRING NOT NULL,
  dmv_id NUMERIC(29),
  begin_date_mod_by STRING,
  end_date_mod_by STRING,
  is_begin_upd_by_sys STRING NOT NULL,
  is_end_upd_by_sys STRING NOT NULL,
  is_active STRING NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
;
