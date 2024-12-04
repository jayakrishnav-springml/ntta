--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Violators_Ct_Del
(
  violator_id NUMERIC(29),
  violator_fname STRING,
  violator_lname STRING,
  violator_fname2 STRING,
  violator_lname2 STRING,
  lic_plate_nbr STRING,
  lic_plate_state STRING,
  phone_nbr STRING,
  email_addr STRING,
  driver_lic_nbr STRING,
  driver_lic_state STRING,
  spanish_only STRING,
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  date_modified DATETIME,
  usage_begin_date DATETIME,
  usage_end_date DATETIME,
  comment_date DATETIME,
  violator_type STRING,
  race STRING,
  gender STRING,
  bounce_count INT64,
  violation_count BIGNUMERIC(48, 10) DEFAULT 0,
  excusal_count INT64,
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
  dps_violator_name INT64,
  docno STRING,
  ownr_id NUMERIC(29),
  vehi_id NUMERIC(29),
  contract_id STRING,
  fleet_file_id NUMERIC(29),
  vin STRING,
  violator_source STRING,
  vltr_creation_reason STRING,
  dmv_id NUMERIC(29),
  begin_date_mod_by STRING,
  end_date_mod_by STRING,
  is_begin_upd_by_sys STRING,
  is_end_upd_by_sys STRING,
  is_active STRING,
  insert_datetime DATETIME NOT NULL
)
;