CREATE TABLE IF NOT EXISTS EDW_TER.Land_Cal_Wk_X
(
  cal_id INT64 NOT NULL,
  cal_x_mxm_id INT64 NOT NULL,
  cal_x_1x1_id INT64 NOT NULL,
  cal_wk_bgn DATE NOT NULL,
  cal_comp_wk_bgn DATE NOT NULL,
  cal_comp_bgn INT64 NOT NULL,
  cal_comp_end INT64 NOT NULL,
  cal_wk_x_bgn DATE NOT NULL,
  cal_wk_x_end DATE NOT NULL
)
;