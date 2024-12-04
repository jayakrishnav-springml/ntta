## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_ALERT_BY_TRAN_CNT_LANE_FRQCY.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Alert_By_Tran_Cnt_Lane_Frqcy
(
  lane_id NUMERIC(29) NOT NULL,
  oracle_row_count INT64,
  date_str STRING NOT NULL,
  hr INT64 NOT NULL,
  wd INT64 NOT NULL,
  wk INT64 NOT NULL,
  local_time DATETIME,
  alert_level INT64,
  alert_message STRING,
  message_sent INT64
)
cluster by lane_id
;
