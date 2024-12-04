-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_TOLL_SERV_ADJ_DET_REPORT_TRUNCATE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Toll_Serv_Adj_Det_Report_Truncate
(
  adj_type STRING,
  location STRING,
  transaction_date DATETIME,
  earned_class BIGNUMERIC(48, 10),
  toll_amt NUMERIC(31, 2),
  premium_amt NUMERIC(31, 2),
  posted_paid_amt NUMERIC(31, 2),
  posted_paid_method STRING,
  posted_date_time DATETIME,
  adjustment_date DATETIME,
  adjustment_amt NUMERIC(31, 2),
  reason_code STRING,
  disposition_code STRING,
  status_date DATETIME,
  updated_by STRING,
  receipt_date DATETIME,
  last_update_date DATETIME,
  last_update_type STRING
)
;
