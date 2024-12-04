CREATE TABLE IF NOT EXISTS EDW_TER.Dto_Cal_Prd_Qtr
(
  cal_id INT64 NOT NULL,
  cal_prd_qtr_bgn DATE NOT NULL,
  cal_prd_qtr_ix INT64 NOT NULL,
  cal_prds_qtr INT64 NOT NULL,
  cal_prd_qtr INT64 NOT NULL,
  cal_prd_qtr_sid STRING,
  cal_prd_qtr_desc_1 STRING,
  cal_prd_qtr_desc_2 STRING,
  etl_sid INT64 NOT NULL,
  etl_chg STRING NOT NULL,
  etl_day DATETIME NOT NULL
)
;