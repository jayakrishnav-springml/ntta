--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Toll_Serv_Sum_Txns
(
  date_type STRING,
  bus_day DATE,
  agency_id NUMERIC(29) DEFAULT 2,
  lane_id NUMERIC(29),
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
  creation_date DATE,
  created_by STRING,
  modified_date DATE,
  modified_by STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by LANE_ID
;
