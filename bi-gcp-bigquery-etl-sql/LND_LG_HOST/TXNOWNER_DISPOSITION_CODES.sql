-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_DISPOSITION_CODES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Disposition_Codes
(
  disposition_code STRING NOT NULL,
  disposition_descr STRING NOT NULL,
  is_active STRING NOT NULL,
  created_by STRING NOT NULL,
  created_date DATETIME NOT NULL,
  modified_by STRING,
  modified_date DATETIME,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
