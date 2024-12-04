-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_TOLL_SERV_PROCESSING_FEE.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Toll_Serv_Processing_Fee
(
  facs_id NUMERIC(29),
  txns_base_fee NUMERIC(31, 2),
  txns_percentage_fee NUMERIC(31, 2),
  iop_processing_fee NUMERIC(31, 2),
  effective_date DATETIME,
  expire_date DATETIME,
  created_by STRING,
  creation_date DATETIME,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by facs_id
;
