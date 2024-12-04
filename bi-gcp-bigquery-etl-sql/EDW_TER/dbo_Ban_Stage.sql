CREATE TABLE IF NOT EXISTS EDW_TER.Ban_Stage
(
  banid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  activeflag INT64 NOT NULL,
  banactionlookupid INT64 NOT NULL,
  actiondate DATETIME NOT NULL,
  banstartdate DATETIME NOT NULL,
  banlocationlookupid INT64 NOT NULL,
  banofficerlookupid INT64 NOT NULL,
  banimpoundservicelookupid INT64 NOT NULL,
  ban_last_update_type STRING NOT NULL,
  ban_last_update_date DATETIME NOT NULL,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING
)
cluster by banid
;
