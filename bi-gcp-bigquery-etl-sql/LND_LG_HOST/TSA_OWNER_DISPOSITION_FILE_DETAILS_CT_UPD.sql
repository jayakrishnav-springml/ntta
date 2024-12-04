-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TSA_OWNER_DISPOSITION_FILE_DETAILS_CT_UPD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Tsa_Owner_Disposition_File_Details_Ct_Upd
(
  disposition_file_detail_id NUMERIC(29) NOT NULL,
  disposition_type_code STRING NOT NULL,
  disposition_file_header_id NUMERIC(29),
  subscriber_unique_id NUMERIC(29) NOT NULL,
  disposition_counter STRING,
  subscriber_id STRING NOT NULL,
  record_type STRING,
  resubmittal_counter STRING,
  revenue_date DATETIME NOT NULL,
  payment_date DATETIME,
  reconciled_date DATETIME,
  reconciled_by STRING,
  transaction_date DATETIME NOT NULL,
  disposition_date DATETIME NOT NULL,
  ntta_disposition_id INT64 NOT NULL,
  disposition_toll_type STRING NOT NULL,
  disposition_toll_amt NUMERIC(33, 4) NOT NULL,
  base_transaction_fee NUMERIC(33, 4),
  variable_transaction_fee NUMERIC(33, 4),
  iop_transaction_fee NUMERIC(33, 4),
  misc_fee1 NUMERIC(33, 4),
  misc_fee2 NUMERIC(33, 4),
  net_payment_amount NUMERIC(33, 4) NOT NULL,
  disposition_code STRING NOT NULL,
  disposition_reason STRING,
  disposition_transponder_id STRING,
  disposition_vehicle_class STRING,
  disposition_license_state STRING,
  disposition_license_plate STRING,
  avi_posted_date DATETIME,
  avi_failed_date DATETIME,
  fare_rule_code STRING,
  base_fee_type_id INT64 NOT NULL,
  variable_fee_type_id INT64 NOT NULL,
  iop_fee_type_id INT64 NOT NULL,
  created_by STRING NOT NULL,
  date_created DATETIME NOT NULL,
  modified_by STRING NOT NULL,
  date_modified DATETIME NOT NULL,
  transaction_file_detail_id NUMERIC(29),
  initial_payment_date DATETIME,
  initial_payment_method STRING,
  subscriber_list_id INT64,
  txn_source STRING,
  home_authority STRING,
  premium NUMERIC(33, 4),
  initial_payment_amount NUMERIC(33, 4),
  insert_datetime DATETIME NOT NULL
)
;
