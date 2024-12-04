CREATE TABLE IF NOT EXISTS EDW_TER.Dto_Cal_Day_Wk
(
  cal_id INT64 NOT NULL,
  cal_day_wk_bgn DATE NOT NULL,
  cal_day_wk_ix INT64 NOT NULL,
  cal_days_wk INT64 NOT NULL,
  cal_day_wk INT64 NOT NULL,
  cal_day_wk_sid STRING,
  cal_day_wk_desc_1 STRING,
  cal_day_wk_desc_2 STRING,
  etl_sid INT64 NOT NULL,
  etl_chg STRING NOT NULL,
  etl_day DATETIME NOT NULL
)
;