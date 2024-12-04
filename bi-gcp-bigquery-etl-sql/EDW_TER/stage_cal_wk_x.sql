
CREATE TABLE IF NOT EXISTS EDW_TER.Stage_Cal_Wk_X
(
  cal_id INT64,
  cal_x_mxm_id INT64,
  cal_x_1x1_id INT64,
  cal_wk_bgn DATETIME,
  cal_comp_wk_bgn DATETIME,
  cal_comp_bgn INT64,
  cal_comp_end INT64,
  cal_wk_x_bgn DATETIME,
  cal_wk_x_end DATETIME,
  etl_sid INT64,
  etl_chg STRING
)
;