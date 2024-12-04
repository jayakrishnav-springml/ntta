## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/stage_cal.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Stage_Cal
(
  cal_id INT64,
  cal_bgn DATE,
  cal_end DATE,
  cal_wk_day_end STRING,
  cal_days_nrml INT64,
  cal_days_leap INT64,
  cal_wks_nrml INT64,
  cal_wks_leap INT64,
  cal_prds_nrml INT64,
  cal_prds_leap INT64,
  cal_qtrs_nrml INT64,
  cal_qtrs_leap INT64,
  cal_seas_nrml INT64,
  cal_seas_leap INT64,
  cal_desc STRING,
  etl_sid INT64,
  etl_chg STRING
)
;
