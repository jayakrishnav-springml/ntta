-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_VIOL_TRANSACTIONS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Viol_Transactions
(
  trans_rec_id NUMERIC(29) NOT NULL,
  host_transaction_id NUMERIC(29) NOT NULL,
  viol_date DATETIME NOT NULL,
  process_flag STRING NOT NULL,
  viol_serial_nbr INT64 NOT NULL,
  isf_serial_nbr NUMERIC(29),
  lc_flg STRING NOT NULL,
  violation_id FLOAT64,
  agency_code STRING,
  tag_id STRING,
  reason_code STRING,
  earned_class INT64 NOT NULL,
  earned_revenue NUMERIC(31, 2) NOT NULL,
  posted_date DATETIME,
  posted_class INT64,
  posted_revenue NUMERIC(31, 2),
  tag_status STRING,
  coin_jam STRING,
  acm_ok STRING,
  avi_ok STRING,
  tag_class INT64,
  lane_id NUMERIC(29) NOT NULL,
  ves_timestamp DATETIME NOT NULL,
  creation_date DATETIME NOT NULL,
  created_by STRING NOT NULL,
  updated_date DATETIME NOT NULL,
  updated_by STRING NOT NULL,
  disposition STRING NOT NULL,
  hia_agcy_id NUMERIC(29),
  viol_status STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by trans_rec_id
;
