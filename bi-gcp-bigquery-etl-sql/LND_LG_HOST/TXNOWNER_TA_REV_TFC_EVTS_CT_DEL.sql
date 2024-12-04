-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_TA_REV_TFC_EVTS_CT_DEL.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Ta_Rev_Tfc_Evts_Ct_Del
(
  txn_id NUMERIC(29),
  date_time DATETIME NOT NULL,
  earned_rev NUMERIC(31, 2),
  actual_rev NUMERIC(31, 2),
  actual_axles INT64,
  creation_date DATETIME NOT NULL,
  tart_id NUMERIC(29),
  opnm_id NUMERIC(29),
  taoc_id NUMERIC(29),
  facs_id NUMERIC(29),
  plaz_id NUMERIC(29),
  lane_id NUMERIC(29),
  taob_id NUMERIC(29),
  txid_id NUMERIC(29),
  pmty_id NUMERIC(29),
  vcly_id NUMERIC(29),
  tauo_id NUMERIC(29),
  earned_axles INT64,
  transaction_file_detail_id NUMERIC(29),
  insert_datetime DATETIME NOT NULL
)
;
