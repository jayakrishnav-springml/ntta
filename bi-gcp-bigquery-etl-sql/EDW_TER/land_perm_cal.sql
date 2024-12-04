CREATE TABLE IF NOT EXISTS EDW_TER.Land_Perm_Cal
(
  cal_id INT64 NOT NULL,
  cal_bgn DATE NOT NULL,
  cal_end DATE NOT NULL,
  cal_wk_day_end STRING NOT NULL,
  cal_days_nrml INT64 NOT NULL,
  cal_days_leap INT64 NOT NULL,
  cal_wks_nrml INT64 NOT NULL,
  cal_wks_leap INT64 NOT NULL,
  cal_prds_nrml INT64 NOT NULL,
  cal_prds_leap INT64 NOT NULL,
  cal_qtrs_nrml INT64 NOT NULL,
  cal_qtrs_leap INT64 NOT NULL,
  cal_seas_nrml INT64 NOT NULL,
  cal_seas_leap INT64 NOT NULL,
  cal_desc STRING NOT NULL
)
;