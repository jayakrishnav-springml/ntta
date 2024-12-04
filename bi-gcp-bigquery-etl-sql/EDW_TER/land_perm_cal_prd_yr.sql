CREATE TABLE IF NOT EXISTS EDW_TER.Land_Perm_Cal_Prd_Yr
(
  cal_id INT64 NOT NULL,
  cal_prd_yr_bgn DATE NOT NULL,
  cal_prd_yr_ix INT64 NOT NULL,
  cal_prd_yr_greg_ix INT64 NOT NULL,
  cal_prds_yr INT64 NOT NULL,
  cal_prd_yr INT64 NOT NULL,
  cal_prd_sea INT64,
  cal_prd_qtr INT64 NOT NULL,
  cal_qtr_yr INT64 NOT NULL,
  cal_yr_adj INT64 NOT NULL,
  cal_prd_yr_sid STRING,
  cal_prd_yr_desc_1 STRING,
  cal_prd_yr_desc_2 STRING
)
;