## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_NET_REV_TFC_EVTS_SUMMARY.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Net_Rev_Tfc_Evts_Summary
(
  day_id INT64,
  lane_id NUMERIC(29),
  pmty_id NUMERIC(29) NOT NULL,
  vcly_id NUMERIC(29) NOT NULL,
  local_time DATETIME,
  time_id INT64,
  txn_cnt INT64,
  ear_rev BIGNUMERIC(44, 6),
  act_rev BIGNUMERIC(46, 8)
)
;
