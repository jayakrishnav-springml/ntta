-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_AVI_TRANSACTIONS_CLR.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Avi_Transactions_Clr
(
  transaction_id NUMERIC(29) NOT NULL,
  transaction_date DATETIME NOT NULL,
  agency_code STRING NOT NULL,
  tag_id STRING NOT NULL,
  facility_id INT64 NOT NULL,
  plaza_id INT64 NOT NULL,
  lane_id INT64 NOT NULL,
  disposition STRING,
  reason_code STRING,
  earned_class INT64,
  earned_revenue NUMERIC(31, 2),
  posted_class INT64,
  posted_revenue NUMERIC(31, 2),
  posted_date_time DATETIME,
  source_code STRING,
  txid_id STRING,
  last_update_date DATETIME,
  last_update_type STRING
)
;
