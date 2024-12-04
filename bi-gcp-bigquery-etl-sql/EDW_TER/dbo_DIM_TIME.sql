CREATE TABLE IF NOT EXISTS EDW_TER.Dim_Time
(
  time_id INT64 NOT NULL,
  hour STRING NOT NULL,
  `12_hour` STRING NOT NULL,
  am_pm STRING NOT NULL,
  `30_minute` STRING NOT NULL,
  `15_minute` STRING NOT NULL,
  `10_minute` STRING NOT NULL,
  `5_minute` STRING NOT NULL,
  minute STRING NOT NULL,
  second STRING NOT NULL
)
cluster by time_id
;
