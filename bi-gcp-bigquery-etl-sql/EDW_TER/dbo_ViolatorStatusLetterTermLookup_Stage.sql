CREATE TABLE IF NOT EXISTS EDW_TER.ViolatorStatusLetterTermLookup_Stage
(
  violatorstatuslettertermlookupid INT64 NOT NULL,
  descr STRING NOT NULL,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by violatorstatuslettertermlookupid
;