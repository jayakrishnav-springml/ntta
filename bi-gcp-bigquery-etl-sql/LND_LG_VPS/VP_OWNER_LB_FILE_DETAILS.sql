-- Translation time: 2024-06-04T08:04:57.852399Z
-- Translation job ID: d189ef38-1420-4658-96a7-29624b482bd7
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_VPS/Tables/VP_OWNER_LB_FILE_DETAILS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_VPS.Vp_Owner_Lb_File_Details
(
  id BIGNUMERIC(48, 10) NOT NULL,
  lb_file_header_id BIGNUMERIC(48, 10) NOT NULL,
  batch_seq_number STRING NOT NULL,
  payment_id STRING,
  document_type_id BIGNUMERIC(48, 10) NOT NULL,
  invoice_number BIGNUMERIC(48, 10) NOT NULL,
  date_paid DATETIME,
  amount_paid NUMERIC(31, 2) NOT NULL,
  method STRING NOT NULL,
  check_number BIGNUMERIC(48, 10),
  deposit_date DATETIME NOT NULL,
  reversal_date DATETIME,
  reversal_reason STRING,
  credit_card_type STRING,
  credit_card_number STRING,
  credit_card_expiration_date DATETIME,
  aba_number STRING NOT NULL,
  bank_account_number STRING NOT NULL,
  drivers_license_number STRING,
  drivers_license_state STRING,
  drivers_dob STRING,
  first_name STRING,
  middle_name STRING,
  last_name STRING,
  company_name STRING,
  address_1 STRING,
  address_2 STRING,
  city STRING,
  state STRING,
  zip STRING,
  zip_plus4 STRING,
  email_address STRING,
  bank_account_type STRING,
  source_type_id BIGNUMERIC(48, 10) NOT NULL,
  phone_number STRING,
  disposition_id BIGNUMERIC(48, 10) NOT NULL,
  date_processed DATETIME,
  date_applied DATETIME,
  amount_due NUMERIC(31, 2),
  disc_amt_due NUMERIC(31, 2),
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  account_number STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
