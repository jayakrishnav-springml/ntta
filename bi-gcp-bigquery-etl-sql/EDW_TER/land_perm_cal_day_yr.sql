CREATE TABLE IF NOT EXISTS EDW_TER.Land_Perm_Cal_Day_Yr
(
  cal_id INT64 NOT NULL,
  cal_day_yr_bgn DATE NOT NULL,
  cal_day_yr_ix INT64 NOT NULL,
  cal_days_yr INT64 NOT NULL,
  cal_day_yr INT64 NOT NULL,
  cal_day_sea INT64,
  cal_day_qtr INT64 NOT NULL,
  cal_day_prd INT64 NOT NULL,
  cal_day_wk INT64 NOT NULL,
  cal_wk_yr INT64 NOT NULL,
  cal_day_yr_sid STRING,
  cal_day_yr_desc_1 STRING,
  cal_day_yr_desc_2 STRING
)
;