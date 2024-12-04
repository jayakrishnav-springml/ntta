CREATE TABLE IF NOT EXISTS EDW_TER.VrbAgencyLookup_Stage
(
  vrbagencylookupid INT64 NOT NULL,
  descr STRING NOT NULL,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by vrbagencylookupid
;