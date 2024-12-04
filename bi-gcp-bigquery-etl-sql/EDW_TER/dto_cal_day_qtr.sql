CREATE TABLE IF NOT EXISTS EDW_TER.Dto_Cal_Day_Qtr
(
  cal_id INT64 NOT NULL,
  cal_day_qtr_bgn DATE NOT NULL,
  cal_day_qtr_ix INT64 NOT NULL,
  cal_days_qtr INT64 NOT NULL,
  cal_day_qtr INT64 NOT NULL,
  cal_day_qtr_sid STRING,
  cal_day_qtr_desc_1 STRING,
  cal_day_qtr_desc_2 STRING,
  etl_sid INT64 NOT NULL,
  etl_chg STRING NOT NULL,
  etl_day DATETIME NOT NULL
)
;