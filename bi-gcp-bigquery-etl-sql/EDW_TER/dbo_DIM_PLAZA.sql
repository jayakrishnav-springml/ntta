CREATE TABLE IF NOT EXISTS EDW_TER.Dim_Plaza
(
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
  agency_name STRING,
  agency_is_iop STRING,
  insert_date DATETIME NOT NULL
)
;
