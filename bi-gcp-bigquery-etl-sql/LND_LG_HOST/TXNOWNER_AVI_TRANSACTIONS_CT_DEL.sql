-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_AVI_TRANSACTIONS_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Avi_Transactions_Ct_Del
(
  transaction_id NUMERIC(29) NOT NULL,
  transaction_date DATETIME NOT NULL,
  agency_code STRING NOT NULL,
  tag_id STRING NOT NULL,
  facility_id INT64 NOT NULL,
  plaza_id INT64 NOT NULL,
  lane_id NUMERIC(29) NOT NULL,
  disposition STRING,
  reason_code STRING,
  earned_class INT64,
  earned_revenue NUMERIC(33, 4),
  posted_class INT64,
  posted_revenue NUMERIC(33, 4),
  posted_date_time DATETIME,
  source_code STRING NOT NULL,
  txid_id STRING,
  creation_date DATETIME NOT NULL,
  acct_id NUMERIC(29),
  transaction_file_detail_id NUMERIC(29),
  insert_datetime DATETIME NOT NULL
)
;
