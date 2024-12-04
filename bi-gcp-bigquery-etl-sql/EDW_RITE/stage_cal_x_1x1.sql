## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/stage_cal_x_1x1.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Stage_Cal_X_1x1
(
  cal_x_1x1_id INT64,
  cal_x_1x1_desc_1 STRING,
  cal_x_1x1_desc_2 STRING,
  etl_sid INT64,
  etl_chg STRING
)
;
