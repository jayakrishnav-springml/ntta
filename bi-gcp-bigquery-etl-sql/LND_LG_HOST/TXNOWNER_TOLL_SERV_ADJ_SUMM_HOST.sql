-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/TXNOWNER_TOLL_SERV_ADJ_SUMM_HOST.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Toll_Serv_Adj_Summ_Host
(
  date_type STRING,
  tran_post_date DATETIME,
  agency_id NUMERIC(29),
  tta_not_post_not_pursble_cnt NUMERIC(29),
  tta_not_post_not_pursble_toll NUMERIC(31, 2),
  tta_not_post_pursble_cnt NUMERIC(29),
  tta_not_post_pursble_toll NUMERIC(31, 2),
  tta_duplicate_cnt NUMERIC(29),
  tta_duplicate_toll NUMERIC(31, 2),
  tta_tagstore_crdt_cnt NUMERIC(29),
  tta_tagstore_crdt_toll NUMERIC(31, 2),
  tta_post_video_trxns_cnt NUMERIC(29),
  tta_post_video_trxns_toll NUMERIC(31, 2),
  tta_post_video_trxns_toll_all NUMERIC(31, 2),
  vta_unpursble_cnt NUMERIC(29),
  vta_unpursble_toll NUMERIC(31, 2),
  vta_user_disp_cnt NUMERIC(29),
  vta_user_disp_toll NUMERIC(31, 2),
  tta_class_adjustment_cnt NUMERIC(29),
  tta_class_adjustment_ear NUMERIC(31, 2),
  tta_class_adjustment_post NUMERIC(31, 2),
  tta_exempt_count NUMERIC(29),
  tta_exempt_earned_rev NUMERIC(31, 2),
  vta_duplicate_cnt NUMERIC(29),
  vta_duplicate_toll NUMERIC(31, 2),
  vta_exempt_count NUMERIC(29),
  vta_exempt_earned_rev NUMERIC(31, 2),
  vta_class_adjustment_count NUMERIC(29),
  vta_class_adjustment_avi_rev NUMERIC(31, 2),
  vta_class_adjustment_toll_rev NUMERIC(31, 2),
  last_update_date DATETIME,
  last_update_type STRING
)
;
