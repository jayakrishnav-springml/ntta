## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_ALERT_BY_TRAN_CNT_LANE_FRQCY_SUMMARY_OLD.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Alert_By_Tran_Cnt_Lane_Frqcy_Summary_Old
(
  wk INT64,
  wd INT64,
  hr INT64,
  lane_id NUMERIC(29),
  plaza_id INT64 NOT NULL,
  years INT64,
  avg_cnt INT64,
  min_cnt INT64,
  max_cnt INT64,
  dh_avg_cnt INT64,
  dh_min_cnt INT64,
  plaza_avg_cnt INT64,
  plaza_min_cnt INT64,
  plaza_max_cnt INT64,
  year_grow INT64
)
;
