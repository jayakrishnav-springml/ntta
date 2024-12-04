
CREATE TABLE IF NOT EXISTS EDW_TER.Stage_Cal
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