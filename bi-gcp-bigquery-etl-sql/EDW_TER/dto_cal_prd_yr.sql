CREATE TABLE IF NOT EXISTS EDW_TER.Dto_Cal_Prd_Yr
(
  cal_id INT64 NOT NULL,
  cal_prd_yr_bgn DATE NOT NULL,
  cal_prd_yr_ix INT64 NOT NULL,
  cal_prds_yr INT64 NOT NULL,
  cal_prd_yr INT64 NOT NULL,
  cal_prd_yr_sid STRING,
  cal_prd_yr_desc_1 STRING,
  cal_prd_yr_desc_2 STRING,
  etl_sid INT64 NOT NULL,
  etl_chg STRING NOT NULL,
  etl_day DATETIME NOT NULL
)
;