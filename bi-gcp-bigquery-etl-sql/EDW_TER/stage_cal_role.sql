CREATE TABLE IF NOT EXISTS EDW_TER.Stage_Cal_Role
(
  cal_role_id INT64 NOT NULL,
  cal_role_ix INT64 NOT NULL,
  cal_role_desc_1 STRING NOT NULL,
  cal_role_desc_2 STRING NOT NULL,
  etl_sid INT64 NOT NULL,
  etl_chg STRING NOT NULL
)
;