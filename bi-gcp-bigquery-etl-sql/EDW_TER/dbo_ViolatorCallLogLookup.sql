CREATE TABLE IF NOT EXISTS EDW_TER.ViolatorCallLogLookup
(
  violatorcallloglookupid INT64 NOT NULL,
  descr STRING NOT NULL,
  insert_date DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by violatorcallloglookupid
;