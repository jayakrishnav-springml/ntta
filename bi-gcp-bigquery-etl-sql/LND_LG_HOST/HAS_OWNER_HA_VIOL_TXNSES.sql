-- Translation time: 2024-06-04T07:57:18.317878Z
-- Translation job ID: b2abff43-eccf-406a-aa5d-053048797d89
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_LG_HOST/Tables/HAS_OWNER_HA_VIOL_TXNSES.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_LG_HOST.Has_Owner_Ha_Viol_Txnses
(
  earned_revenue NUMERIC(29) NOT NULL,
  posted_revenue NUMERIC(29) NOT NULL,
  bus_day DATETIME NOT NULL,
  hvt_id NUMERIC(29) NOT NULL,
  txn_count INT64,
  lane_lane_id NUMERIC(29) NOT NULL,
  start_time DATETIME,
  end_time DATETIME,
  summ_time DATETIME,
  veh_no_fund_count INT64,
  veh_part_vio_pmt_cnt INT64,
  veh_vio_cnt INT64,
  veh_vio_rev NUMERIC(29),
  tot_vio_sent_cnt INT64,
  tot_vio_sent_rev NUMERIC(29),
  tot_vio_posted_cnt INT64,
  tot_vio_posted_rev NUMERIC(29),
  tot_vio_processed_cnt INT64,
  tot_vio_processed_rev NUMERIC(29),
  veh_zero_vio_cnt NUMERIC(29),
  veh_avi_vio_cnt NUMERIC(29),
  summary_type STRING,
  hia_agcy_id NUMERIC(29),
  posted_day DATETIME,
  last_update_type STRING,
  last_update_date DATETIME
)
;
