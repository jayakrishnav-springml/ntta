CREATE TABLE IF NOT EXISTS EDW_TER.Stage_Cal_Qtr_Yr
(
  cal_id INT64,
  cal_qtr_yr_bgn DATE,
  cal_qtr_yr_ix INT64,
  cal_qtrs_yr INT64,
  cal_qtr_yr INT64,
  cal_qtr_yr_sid STRING,
  cal_qtr_yr_desc_1 STRING,
  cal_qtr_yr_desc_2 STRING,
  etl_sid INT64,
  etl_chg STRING
)
;