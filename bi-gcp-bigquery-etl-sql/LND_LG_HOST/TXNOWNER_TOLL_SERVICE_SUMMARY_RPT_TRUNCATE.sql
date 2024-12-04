--Translated manually via BQ Interactive tool

CREATE TABLE IF NOT EXISTS LND_LG_HOST.TxnOwner_Toll_Service_Summary_Rpt_Truncate
(
  tssr_id NUMERIC(29) NOT NULL,
  transaction_date DATE,
  posted_date DATE,
  disposition STRING,
  agency_id NUMERIC(29) DEFAULT 2,
  lane_id NUMERIC(29),
  avi_cnt NUMERIC(29),
  total_system_toll_trnspnder NUMERIC(31, 2),
  total_regional_toll_trnspnder NUMERIC(31, 2),
  video_cnt NUMERIC(29),
  total_system_toll_video NUMERIC(31, 2),
  total_regional_toll_video NUMERIC(31, 2),
  total_base_txns_fee NUMERIC(31, 2),
  total_perct_txns_fee NUMERIC(31, 2),
  total_iop_txns_fee NUMERIC(31, 2),
  creation_date DATETIME,
  created_by STRING,
  modified_date DATETIME,
  modified_by STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by tssr_id
;
