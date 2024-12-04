CREATE TABLE IF NOT EXISTS EDW_TER.ViolatorStatusLetterBan2ndLookup
(
  violatorstatusletterban2ndlookupid INT64 NOT NULL,
  descr STRING NOT NULL,
  insert_date DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by violatorstatusletterban2ndlookupid
;