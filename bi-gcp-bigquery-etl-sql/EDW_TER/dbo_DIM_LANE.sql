CREATE TABLE IF NOT EXISTS EDW_TER.Dim_Lane
(
  lane_id NUMERIC(29) NOT NULL,
  lane_abbrev STRING NOT NULL,
  lane_name STRING,
  lane_direction STRING,
  plaza_id NUMERIC(29) NOT NULL,
  plaza_abbrev STRING NOT NULL,
  plaza_name STRING NOT NULL,
  plaza_latitude BIGNUMERIC(50, 12),
  plaza_longitude BIGNUMERIC(50, 12),
  facility_id NUMERIC(29) NOT NULL,
  facility_abbrev STRING NOT NULL,
  facility_name STRING NOT NULL,
  agency_id NUMERIC(29) NOT NULL,
  agency_abbrev STRING NOT NULL,
  agency_name STRING NOT NULL,
  agency_is_iop STRING,
  insert_date DATETIME NOT NULL
)
;
