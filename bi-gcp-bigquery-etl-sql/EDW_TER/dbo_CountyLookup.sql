CREATE TABLE IF NOT EXISTS EDW_TER.CountyLookup
(
  countylookupid INT64 NOT NULL,
  descr STRING NOT NULL,
  participatingcounty STRING NOT NULL,
  countygroup STRING NOT NULL,
  insert_date DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by countylookupid
;