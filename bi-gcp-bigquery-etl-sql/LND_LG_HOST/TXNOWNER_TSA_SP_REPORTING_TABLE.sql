-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_TSA_SP_REPORTING_TABLE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Tsa_Sp_Reporting_Table
(
  transaction_id NUMERIC(29),
  received_date DATETIME,
  transaction_date DATETIME,
  lane_id NUMERIC(29),
  transaction_type STRING,
  earned_class NUMERIC(29),
  home_authority STRING,
  system_toll FLOAT64 NOT NULL,
  regional_toll FLOAT64 NOT NULL,
  total_toll NUMERIC(33, 4) NOT NULL,
  premium NUMERIC(33, 4) NOT NULL,
  payment NUMERIC(33, 4) NOT NULL,
  payment_method STRING,
  payment_date DATETIME,
  payment_variance NUMERIC(33, 4),
  base_txn_fee NUMERIC(33, 4) NOT NULL,
  variable_txn_fee NUMERIC(33, 4) NOT NULL,
  iop_txn_fee NUMERIC(33, 4) NOT NULL,
  total_txn_fee NUMERIC(33, 4) NOT NULL,
  net_regional_toll NUMERIC(33, 4) NOT NULL,
  net_tsa_payment NUMERIC(33, 4) NOT NULL,
  tsa_disposition STRING,
  ntta_txn_disposition STRING,
  disposition_reason STRING,
  source_system STRING,
  transponder_id STRING,
  payment_confirmation_date DATETIME,
  contract_type STRING,
  lane_name STRING,
  payment_txn_id NUMERIC(29),
  txn_source STRING,
  subscriber_unique_id NUMERIC(29),
  disposition_type STRING,
  adjusted_date DATETIME,
  facility_id NUMERIC(29),
  plaza_id NUMERIC(29),
  facility_name STRING,
  plaza_name STRING,
  disposition_file_detail_id NUMERIC(29),
  transaction_file_detail_id NUMERIC(29),
  run_datetime DATETIME,
  ves_serial_no NUMERIC(29),
  disposition_file_name STRING,
  disposition_file_date DATETIME,
  record_type STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
