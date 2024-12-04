CREATE TABLE IF NOT EXISTS EDW_TER.BanOfficerLookup
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
  insert_date DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by banofficerlookupid
;
