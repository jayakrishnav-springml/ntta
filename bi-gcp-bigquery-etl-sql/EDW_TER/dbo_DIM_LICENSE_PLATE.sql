CREATE TABLE IF NOT EXISTS EDW_TER.Dim_License_Plate
(
  license_plate_id INT64 NOT NULL,
  license_plate_nbr STRING NOT NULL,
  license_plate_state STRING NOT NULL
)
cluster by license_plate_id
;
