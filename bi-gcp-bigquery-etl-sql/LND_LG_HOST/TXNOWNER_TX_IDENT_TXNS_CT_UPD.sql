-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_TX_IDENT_TXNS_CT_UPD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Tx_Ident_Txns_Ct_Upd
(
  txn_id NUMERIC(29),
  received_date DATETIME,
  status_flg STRING,
  msg_contents STRING,
  txii_id NUMERIC(29),
  txid_id NUMERIC(29),
  devn_id NUMERIC(29),
  txuf_id NUMERIC(29),
  insert_datetime DATETIME NOT NULL
)
;
