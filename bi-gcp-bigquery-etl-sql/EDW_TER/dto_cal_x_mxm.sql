CREATE TABLE IF NOT EXISTS EDW_TER.Dto_Cal_X_Mxm
(
  cal_x_mxm_id INT64 NOT NULL,
  cal_x_mxm_attrib STRING NOT NULL,
  cal_x_mxm_desc_1 STRING NOT NULL,
  cal_x_mxm_desc_2 STRING NOT NULL,
  etl_sid INT64 NOT NULL,
  etl_chg STRING NOT NULL,
  etl_day DATETIME NOT NULL
)
;