-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_TX_TA_IDENTITIES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Tx_Ta_Identities
(
  name STRING NOT NULL,
  txid_desc STRING NOT NULL,
  created_by STRING NOT NULL,
  creation_date DATE NOT NULL,
  updated_by STRING NOT NULL,
  updated_date DATE NOT NULL,
  txid_id NUMERIC(29),
  txbe_id NUMERIC(29),
  transaction_rpt_name STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
