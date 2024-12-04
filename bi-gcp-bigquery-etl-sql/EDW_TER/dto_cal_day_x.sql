CREATE TABLE IF NOT EXISTS EDW_TER.Dto_Cal_Day_X
(
  cal_id INT64 NOT NULL,
  cal_x_mxm_id INT64 NOT NULL,
  cal_x_1x1_id INT64 NOT NULL,
  cal_day_bgn DATE NOT NULL,
  cal_comp_day_bgn DATE NOT NULL,
  cal_comp_bgn INT64 NOT NULL,
  cal_comp_end INT64 NOT NULL,
  cal_day_x_bgn DATE NOT NULL,
  cal_day_x_end DATE NOT NULL,
  etl_sid INT64 NOT NULL,
  etl_chg STRING NOT NULL,
  etl_day DATETIME NOT NULL
)
;