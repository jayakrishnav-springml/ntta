CREATE TABLE IF NOT EXISTS EDW_TER.Dim_State
(
  state_code STRING NOT NULL,
  state_name STRING NOT NULL,
  state_latitude BIGNUMERIC(50, 12) NOT NULL,
  state_longitude BIGNUMERIC(50, 12) NOT NULL
)
;
