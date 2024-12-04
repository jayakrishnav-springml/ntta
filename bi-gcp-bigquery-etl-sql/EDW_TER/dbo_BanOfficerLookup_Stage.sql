CREATE TABLE IF NOT EXISTS EDW_TER.BanOfficerLookup_Stage
(
  banofficerlookupid INT64 NOT NULL,
  lastname STRING NOT NULL,
  firstname STRING NOT NULL,
  phonenbr STRING,
  radionbr STRING,
  unit STRING,
  registration STRING,
  patrolcar STRING,
  area STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by banofficerlookupid
;