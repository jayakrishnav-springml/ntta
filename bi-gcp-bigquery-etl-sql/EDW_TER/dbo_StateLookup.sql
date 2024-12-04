CREATE TABLE IF NOT EXISTS EDW_TER.Statelookup
(
  statelookupid INT64 NOT NULL,
  statecode STRING,
  descr STRING NOT NULL,
  state_latitude BIGNUMERIC(50, 12) NOT NULL,
  state_longitude BIGNUMERIC(50, 12) NOT NULL,
  insert_date DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by statelookupid
;