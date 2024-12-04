## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/stage_cal_day_x.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Stage_Cal_Day_X
(
  cal_id INT64,
  cal_x_mxm_id INT64,
  cal_x_1x1_id INT64,
  cal_day_bgn DATETIME,
  cal_comp_day_bgn DATETIME,
  cal_comp_bgn INT64,
  cal_comp_end INT64,
  cal_day_x_bgn DATETIME,
  cal_day_x_end DATETIME,
  etl_sid INT64,
  etl_chg STRING
)
;
