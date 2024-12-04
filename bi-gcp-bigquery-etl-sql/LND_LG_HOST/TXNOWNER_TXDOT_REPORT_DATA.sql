-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_TXDOT_REPORT_DATA.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Txdot_Report_Data
(
  transaction_id NUMERIC(29),
  subscriber_unique_id NUMERIC(29),
  tsa_disposition_code STRING,
  tsa_disposition STRING,
  disposition_type_code STRING,
  disposition_reason_code STRING,
  disposition_reason STRING,
  transaction_date DATETIME,
  received_date DATETIME,
  disposition_date DATETIME,
  process_date DATETIME,
  payment_date DATETIME,
  adjusted_date DATETIME,
  transaction_type_code STRING,
  transaction_type STRING,
  ntta_txn_disposition_id INT64,
  ntta_txn_disposition STRING,
  disposition_file_detail_id NUMERIC(29) NOT NULL,
  transaction_file_detail_id NUMERIC(29),
  facility_id NUMERIC(29),
  plaza_id NUMERIC(29),
  lane_id NUMERIC(29),
  paid_authority STRING,
  payment_method STRING,
  payment NUMERIC(33, 4),
  base_txn_fee NUMERIC(33, 4),
  variable_txn_fee NUMERIC(33, 4),
  iop_txn_fee NUMERIC(33, 4),
  total_toll NUMERIC(31, 2),
  net_tsa_payment NUMERIC(33, 4),
  subscriber_id STRING,
  modified_by STRING,
  date_modified DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
