CREATE TABLE IF NOT EXISTS EDW_TER.Facility
(
  facility_id NUMERIC(29) NOT NULL,
  facility_abbrev STRING NOT NULL,
  facility_name STRING NOT NULL,
  agency_id NUMERIC(29) NOT NULL,
  agency_abbrev STRING NOT NULL,
  agency_name STRING NOT NULL,
  agency_is_iop STRING NOT NULL,
  insert_date DATETIME NOT NULL
)
;
