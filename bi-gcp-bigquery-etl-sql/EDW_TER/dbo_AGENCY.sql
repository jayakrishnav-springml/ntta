CREATE TABLE IF NOT EXISTS EDW_TER.Agency
(
  agency_id NUMERIC(29) NOT NULL,
  agency_abbrev STRING NOT NULL,
  agency_name STRING NOT NULL,
  agency_is_iop STRING NOT NULL,
  insert_date DATETIME NOT NULL
)
cluster by agency_id
;
