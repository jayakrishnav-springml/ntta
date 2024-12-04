CREATE TABLE IF NOT EXISTS EDW_TER.Ban
(
  banid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  activeflag INT64 NOT NULL,
  banactionlookupid INT64 NOT NULL,
  actiondate DATE NOT NULL,
  banstartdate DATE NOT NULL,
  banlocationlookupid INT64 NOT NULL,
  banofficerlookupid INT64 NOT NULL,
  banimpoundservicelookupid INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  insert_date DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL
)
;