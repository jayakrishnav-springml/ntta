CREATE TABLE IF NOT EXISTS EDW_TER.Dto_Cal_Mxm_Wk_Prd
(
  cal_id INT64 NOT NULL,
  cal_wk_bgn DATE NOT NULL,
  cal_prd_bgn DATE NOT NULL,
  etl_sid INT64 NOT NULL,
  etl_chg STRING NOT NULL,
  etl_day DATETIME NOT NULL
)
;