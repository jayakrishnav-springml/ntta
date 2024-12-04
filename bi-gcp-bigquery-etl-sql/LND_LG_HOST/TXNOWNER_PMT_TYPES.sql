-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_PMT_TYPES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Pmt_Types
(
  pmty_desc STRING NOT NULL,
  note STRING,
  created_by STRING NOT NULL,
  creation_date DATETIME NOT NULL,
  updated_by STRING NOT NULL,
  updated_date DATETIME NOT NULL,
  pmty_id NUMERIC(29) NOT NULL,
  code STRING,
  exp_ptc_id INT64,
  ear_ptc_id INT64,
  is_misclassable STRING,
  displayed STRING NOT NULL,
  pmty_order INT64 NOT NULL,
  last_update_date DATETIME,
  last_update_type STRING
)
cluster by pmty_id
;
