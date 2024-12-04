CREATE TABLE IF NOT EXISTS EDW_TER.Stage_Cal_Yr
(
  cal_id INT64,
  cal_yr_bgn DATE,
  cal_yr_end DATE,
  cal_yr_leap INT64,
  cal_yr_sid STRING,
  cal_yr_desc_1 STRING,
  cal_yr_desc_2 STRING,
  etl_sid INT64,
  etl_chg STRING
)
;