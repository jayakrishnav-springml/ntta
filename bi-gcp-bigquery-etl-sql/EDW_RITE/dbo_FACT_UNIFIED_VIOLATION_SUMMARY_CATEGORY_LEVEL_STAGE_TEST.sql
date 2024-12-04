## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_UNIFIED_VIOLATION_SUMMARY_CATEGORY_LEVEL_STAGE_TEST.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Unified_Violation_Summary_Category_Level_Stage_Test
(
  day_id INT64 NOT NULL,
  lane_id NUMERIC(29) NOT NULL,
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
  end_level STRING,
  end_level_name STRING,
  source_code STRING NOT NULL,
  viol_status STRING NOT NULL,
  viol_type STRING NOT NULL,
  out_of_state_ind INT64 NOT NULL,
  deleted INT64 NOT NULL,
  not_trans_review_status_abbrev STRING NOT NULL,
  invoice_stage_id INT64 NOT NULL,
  amount BIGNUMERIC(40, 2),
  txn_cnt INT64,
  pos_rev BIGNUMERIC(46, 8),
  ear_rev BIGNUMERIC(44, 6),
  toll_paid BIGNUMERIC(40, 2),
  split_amount BIGNUMERIC(40, 2),
  amt_paid BIGNUMERIC(40, 2),
  fees_paid BIGNUMERIC(40, 2)
)
;
