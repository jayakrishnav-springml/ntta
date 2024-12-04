-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_DPS_TRANSACTIONS_TRUNCATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Dps_Transactions_Truncate
(
  dps_transaction_id INT64 NOT NULL,
  citation_nbr STRING NOT NULL,
  citation_date DATETIME NOT NULL,
  dob DATETIME NOT NULL,
  county STRING NOT NULL,
  court_name STRING NOT NULL,
  drivers_lic_nbr STRING NOT NULL,
  drivers_lic_state STRING NOT NULL,
  mile_marker INT64 NOT NULL,
  region STRING NOT NULL,
  district STRING NOT NULL,
  area STRING NOT NULL,
  po_emp_id INT64 NOT NULL,
  precinct STRING NOT NULL,
  race_sex STRING NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  accident STRING NOT NULL,
  po_name STRING NOT NULL,
  violator_fname STRING NOT NULL,
  violator_lname STRING NOT NULL,
  violator_address STRING NOT NULL,
  violator_city STRING NOT NULL,
  violator_state STRING NOT NULL,
  violator_zip_code STRING NOT NULL,
  ssn INT64,
  vehicle_color STRING,
  vehicle_year INT64,
  vehicle_model STRING,
  vehicle_make STRING,
  lane_cust_descr STRING NOT NULL,
  judge STRING NOT NULL,
  judge_address STRING NOT NULL,
  judge_city STRING NOT NULL,
  judge_state STRING NOT NULL,
  judge_zip_code STRING,
  judge_phone_nbr STRING,
  appearance_date DATETIME,
  disposition STRING NOT NULL,
  date_created DATETIME NOT NULL,
  created_by STRING NOT NULL,
  date_modified DATETIME,
  modified_by STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
