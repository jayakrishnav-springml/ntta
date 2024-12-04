-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_TER_Violators.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.TER_Violators
(
  violator_id INT64 NOT NULL,
  vid_seq INT64 NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  vehicle_make STRING,
  vehicle_model STRING,
  vehicle_year STRING,
  lic_plate_state STRING NOT NULL,
  vin STRING,
  docno STRING,
  primary_hv_fname STRING,
  primary_hv_lname STRING,
  secondary_hv_fname STRING,
  secondary_hv_lname STRING,
  hv_designation_start_date DATETIME,
  earliest_hv_tran_date DATETIME,
  latest_hv_tran_date DATETIME,
  rite_address_status STRING,
  rite_address1 STRING,
  rite_address2 STRING,
  rite_city STRING,
  rite_state STRING,
  rite_zip_code STRING,
  rite_plus4 STRING,
  hv_q_amount_due NUMERIC(33, 4),
  hv_q_tolls_due NUMERIC(33, 4),
  hv_q_transactions INT64,
  hv_q_fees_due NUMERIC(33, 4),
  total_amount_due NUMERIC(33, 4),
  total_tolls_due NUMERIC(33, 4),
  total_fees_due NUMERIC(33, 4),
  total_citation_count INT64,
  total_transactions_count INT64,
  phone_nbr STRING,
  email_addr STRING,
  drivers_license STRING,
  drivers_license_state STRING,
  secondary_drivers_license STRING,
  secondary_drivers_license_st STRING,
  registration_county STRING,
  registration_date_next_month INT64,
  registration_date_next_year INT64,
  admin_hearing_county STRING
)
;
