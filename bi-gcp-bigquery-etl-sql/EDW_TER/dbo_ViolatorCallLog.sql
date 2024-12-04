CREATE TABLE IF NOT EXISTS EDW_TER.ViolatorCallLog
(
  violatorcalllogid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  violatorcallloglookupid INT64 NOT NULL,
  outgoingcallflag INT64 NOT NULL,
  phonenbr STRING,
  connectedflag INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  insert_date DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL
)
;