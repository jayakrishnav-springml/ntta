CREATE TABLE IF NOT EXISTS EDW_TER.CountyLookup_Stage
(
  countylookupid INT64 NOT NULL,
  descr STRING NOT NULL,
  participatingcounty INT64 NOT NULL,
  countygroup STRING NOT NULL,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by countylookupid
;