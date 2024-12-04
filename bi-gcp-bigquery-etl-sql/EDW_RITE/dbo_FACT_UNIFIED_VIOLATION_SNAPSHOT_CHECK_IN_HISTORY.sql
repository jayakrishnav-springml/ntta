## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_UNIFIED_VIOLATION_SNAPSHOT_CHECK_IN_HISTORY.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Unified_Violation_Snapshot_Check_In_History
(
  tart_id NUMERIC(29) NOT NULL,
  month_id INT64,
  level_0_diff STRING,
  level_1_diff STRING,
  level_2_diff STRING,
  level_3_diff STRING,
  level_4_diff STRING,
  level_5_diff STRING,
  level_6_diff STRING,
  level_7_diff STRING,
  level_8_diff STRING,
  level_9_diff STRING,
  level_10_diff STRING,
  day_id_diff STRING,
  pmty_id_diff STRING,
  vcly_id_diff STRING,
  avi_tag_status_diff STRING,
  lane_id_diff STRING,
  local_time_diff STRING,
  ear_rev_diff STRING,
  pos_rev_diff STRING,
  txid_id_diff STRING,
  transaction_file_detail_id_diff STRING,
  lane_viol_id_diff STRING,
  viol_date_diff STRING,
  axle_count_diff STRING,
  lane_viol_status_diff STRING,
  lane_review_status_diff STRING,
  violation_code_diff STRING,
  viol_created_diff STRING,
  license_plate_id_diff STRING,
  lic_plate_nbr_diff STRING,
  lic_plate_state_diff STRING,
  out_of_state_ind_diff STRING,
  review_date_diff STRING,
  viol_reject_type_diff STRING,
  toll_due_diff STRING,
  toll_paid_diff STRING,
  violation_id_diff STRING,
  status_date_diff STRING,
  viol_type_diff STRING,
  driver_lic_state_diff STRING,
  violator_id_diff STRING,
  viol_status_diff STRING,
  transaction_id_diff STRING,
  disposition_diff STRING,
  vtoll_send_date_diff STRING,
  date_excused_diff STRING,
  excused_reason_diff STRING,
  excused_by_diff STRING,
  ttxn_id_diff STRING,
  amount_diff STRING,
  posted_date_diff STRING,
  posted_day_id_diff STRING,
  source_code_diff STRING,
  acct_id_diff STRING,
  tag_id_diff STRING,
  tag_agency_id_diff STRING,
  dmv_sts_diff STRING,
  txn_name_diff STRING,
  not_trans_review_status_abbrev_diff STRING,
  lvl_tvl_diff STRING,
  vbi_invoice_id_diff STRING,
  viol_invoice_id_diff STRING,
  payment_date_diff STRING,
  deposite_date_diff STRING,
  split_amount_diff STRING,
  fees_paid_diff STRING,
  amt_paid_diff STRING,
  vbi_invoice_date_diff STRING,
  vbi_status_diff STRING,
  vi_invoice_date_diff STRING,
  viol_inv_status_diff STRING,
  invoice_stage_id_diff STRING,
  deleted_diff STRING
)
CLUSTER BY tart_id;
