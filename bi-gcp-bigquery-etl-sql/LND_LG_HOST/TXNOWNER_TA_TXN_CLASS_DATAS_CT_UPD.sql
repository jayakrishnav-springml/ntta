-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_TA_TXN_CLASS_DATAS_CT_UPD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Ta_Txn_Class_Datas_Ct_Upd
(
  rev_axle_ct NUMERIC(29),
  att_axles INT64,
  att_class NUMERIC(29),
  att_fare NUMERIC(31, 2),
  pre_axles INT64,
  pre_class NUMERIC(29),
  pre_fare NUMERIC(31, 2),
  mid_loop_cts NUMERIC(29),
  entry_loop_cts NUMERIC(29),
  exit_loop_cts NUMERIC(29),
  unusual_occ_cd STRING,
  discrepancy STRING,
  cd_id NUMERIC(29) NOT NULL,
  tart_id NUMERIC(29) NOT NULL,
  fwd_axle_ct NUMERIC(29),
  fwd_axles NUMERIC(29),
  insert_datetime DATETIME NOT NULL
)
;
