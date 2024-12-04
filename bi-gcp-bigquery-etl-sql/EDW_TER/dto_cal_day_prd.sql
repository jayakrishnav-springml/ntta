CREATE TABLE IF NOT EXISTS EDW_TER.Dto_Cal_Day_Prd
(
  cal_id INT64 NOT NULL,
  cal_day_prd_bgn DATE NOT NULL,
  cal_day_prd_ix INT64 NOT NULL,
  cal_days_prd INT64 NOT NULL,
  cal_day_prd INT64 NOT NULL,
  cal_day_prd_sid STRING,
  cal_day_prd_desc_1 STRING,
  cal_day_prd_desc_2 STRING,
  etl_sid INT64 NOT NULL,
  etl_chg STRING NOT NULL,
  etl_day DATETIME NOT NULL
)
;