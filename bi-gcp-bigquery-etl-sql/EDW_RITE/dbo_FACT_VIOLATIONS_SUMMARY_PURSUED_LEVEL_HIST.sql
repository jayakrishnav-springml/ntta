## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_VIOLATIONS_SUMMARY_PURSUED_LEVEL_HIST.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Violations_Summary_Pursued_Level_Hist
(
  partition_date DATE,
  day_id INT64,
  cal_weekid INT64,
  cal_monthid INT64,
  cal_quarterid INT64,
  cal_yearid INT64,
  lane_id NUMERIC(29),
  lane_abbrev STRING,
  vcly_id INT64 NOT NULL,
  level_0 STRING,
  level_1 STRING,
  level_2 STRING,
  status STRING,
  status_descr STRING,
  txn_cnt INT64,
  pos_rev BIGNUMERIC(40, 2),
  act_rev BIGNUMERIC(40, 2),
  adj_rev BIGNUMERIC(40, 2)
)
;
