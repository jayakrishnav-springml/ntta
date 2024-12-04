## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Unified_Violation_Summary_Category_Level
(
  day_id INT64 NOT NULL,
  lane_id INT64 NOT NULL,
  vcly_id INT64 NOT NULL,
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
  end_level STRING NOT NULL,
  lvl_tvl STRING NOT NULL,
  source_code STRING NOT NULL,
  viol_status STRING NOT NULL,
  manual_viol_flag INT64 NOT NULL,
  out_of_state_ind INT64 NOT NULL,
  deleted INT64 NOT NULL,
  not_trans_review_status_abbrev STRING NOT NULL,
  invoice_stage_id INT64 NOT NULL,
  iop_flag INT64 NOT NULL,
  fleet_flag INT64 NOT NULL,
  unpursuable_flag INT64 NOT NULL,
  bad_address_flag INT64 NOT NULL,
  amount BIGNUMERIC(40, 2) NOT NULL,
  txn_cnt INT64 NOT NULL,
  pos_rev BIGNUMERIC(40, 2) NOT NULL,
  ear_rev BIGNUMERIC(40, 2) NOT NULL,
  toll_paid BIGNUMERIC(40, 2) NOT NULL,
  split_amount BIGNUMERIC(40, 2) NOT NULL,
  amt_paid BIGNUMERIC(40, 2) NOT NULL,
  fees_paid BIGNUMERIC(40, 2) NOT NULL,
  adj_rev BIGNUMERIC(40, 2) NOT NULL,
  posted_rev BIGNUMERIC(40, 2) NOT NULL
)
;
