## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_UNIFIED_VIOLATION_PREV_FROM_2012_TRUNCATE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Unified_Violation_Prev_From_2012_Truncate
(
  level_0 STRING NOT NULL,
  level_1 STRING NOT NULL,
  level_2 STRING NOT NULL,
  level_3 STRING NOT NULL,
  level_4 STRING NOT NULL,
  level_5 STRING NOT NULL,
  level_6 STRING NOT NULL,
  level_7 STRING NOT NULL,
  level_8 STRING NOT NULL,
  level_9 STRING NOT NULL,
  level_10 STRING NOT NULL,
  tart_id NUMERIC(29) NOT NULL,
  day_id INT64 NOT NULL,
  pmty_id NUMERIC(29) NOT NULL,
  vcly_id NUMERIC(29) NOT NULL,
  avi_tag_status STRING NOT NULL,
  lane_id NUMERIC(29) NOT NULL,
  local_time DATETIME NOT NULL,
  ear_rev NUMERIC(35, 6) NOT NULL,
  pos_rev NUMERIC(37, 8) NOT NULL,
  txid_id NUMERIC(29) NOT NULL,
  transaction_file_detail_id NUMERIC(29) NOT NULL,
  lane_viol_id NUMERIC(29) NOT NULL,
  viol_date DATETIME NOT NULL,
  axle_count NUMERIC(29) NOT NULL,
  lane_viol_status STRING NOT NULL,
  lane_review_status STRING NOT NULL,
  violation_code INT64 NOT NULL,
  viol_created STRING NOT NULL,
  license_plate_id INT64 NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  out_of_state_ind INT64 NOT NULL,
  review_date DATETIME NOT NULL,
  viol_reject_type STRING NOT NULL,
  toll_due NUMERIC(31, 2) NOT NULL,
  toll_paid NUMERIC(31, 2) NOT NULL,
  violation_id NUMERIC(29) NOT NULL,
  status_date DATETIME NOT NULL,
  viol_type STRING NOT NULL,
  driver_lic_state STRING NOT NULL,
  violator_id NUMERIC(29) NOT NULL,
  viol_status STRING NOT NULL,
  transaction_id NUMERIC(29) NOT NULL,
  disposition STRING NOT NULL,
  vtoll_send_date DATETIME NOT NULL,
  date_excused DATETIME NOT NULL,
  excused_reason STRING NOT NULL,
  excused_by STRING NOT NULL,
  ttxn_id INT64 NOT NULL,
  amount NUMERIC(31, 2) NOT NULL,
  posted_date DATETIME NOT NULL,
  posted_day_id INT64 NOT NULL,
  source_code STRING NOT NULL,
  acct_id INT64 NOT NULL,
  tag_id STRING NOT NULL,
  tag_agency_id STRING NOT NULL,
  dmv_sts STRING NOT NULL,
  txn_name STRING NOT NULL,
  not_trans_review_status_abbrev STRING NOT NULL,
  lvl_tvl STRING NOT NULL,
  vbi_invoice_id NUMERIC(29) NOT NULL,
  viol_invoice_id NUMERIC(29) NOT NULL,
  payment_date DATETIME NOT NULL,
  deposite_date DATETIME NOT NULL,
  split_amount NUMERIC(31, 2) NOT NULL,
  fees_paid NUMERIC(31, 2) NOT NULL,
  amt_paid NUMERIC(31, 2) NOT NULL,
  vbi_invoice_date DATETIME NOT NULL,
  vbi_status STRING NOT NULL,
  vi_invoice_date DATE NOT NULL,
  viol_inv_status STRING NOT NULL,
  invoice_stage_id INT64 NOT NULL,
  deleted INT64 NOT NULL,
  data_start_date DATE NOT NULL,
  data_end_date DATE NOT NULL
)
;
