CREATE TABLE IF NOT EXISTS EDW_TER.Dim_Vehicle
(
  vehicle_id INT64 NOT NULL,
  vehicle_make STRING NOT NULL,
  vehicle_model STRING NOT NULL,
  vehicle_year STRING NOT NULL,
  insert_datetime DATETIME NOT NULL
)
cluster by vehicle_id
;