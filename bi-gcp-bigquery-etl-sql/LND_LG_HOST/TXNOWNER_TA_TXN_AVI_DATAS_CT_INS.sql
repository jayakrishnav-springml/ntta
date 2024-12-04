-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_TA_TXN_AVI_DATAS_CT_INS.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Ta_Txn_Avi_Datas_Ct_Ins
(
  avi_reader_nbr STRING NOT NULL,
  avi_tag_class STRING NOT NULL,
  avi_tag_id STRING NOT NULL,
  avi_plaza_and_ln_id STRING NOT NULL,
  avi_tag_status STRING NOT NULL,
  avi_handshake STRING,
  avi_year STRING NOT NULL,
  avi_month STRING NOT NULL,
  avi_day STRING NOT NULL,
  avi_hour STRING NOT NULL,
  avi_minute STRING NOT NULL,
  avi_second STRING NOT NULL,
  tad_id NUMERIC(29) NOT NULL,
  tart_id NUMERIC(29),
  tag_agency STRING,
  insert_datetime DATETIME NOT NULL
)
;
