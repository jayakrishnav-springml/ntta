CREATE TABLE IF NOT EXISTS EDW_TER.Dto_Cal_Load
(
  cal_load_day_bgn DATE NOT NULL,
  cal_dflt_day_bgn DATE NOT NULL,
  cal_dflt_day_end DATE NOT NULL,
  etl_sid INT64 NOT NULL,
  etl_chg STRING NOT NULL,
  etl_day DATETIME NOT NULL
)
;