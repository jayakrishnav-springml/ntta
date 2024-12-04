CREATE TABLE IF NOT EXISTS EDW_TER.Land_Perm_Cal_Qtr_Yr
(
  cal_id INT64 NOT NULL,
  cal_qtr_yr_bgn DATE NOT NULL,
  cal_qtr_yr_ix INT64 NOT NULL,
  cal_qtrs_yr INT64 NOT NULL,
  cal_qtr_yr INT64 NOT NULL,
  cal_qtr_sea INT64 NOT NULL,
  cal_sea_yr INT64 NOT NULL,
  cal_qtr_yr_sid STRING,
  cal_qtr_yr_desc_1 STRING,
  cal_qtr_yr_desc_2 STRING
)
;