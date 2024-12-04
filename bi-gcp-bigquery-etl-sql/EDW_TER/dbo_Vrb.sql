CREATE TABLE IF NOT EXISTS EDW_TER.Vrb
(
  vrbid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  activeflag INT64 NOT NULL,
  vrbstatuslookupid INT64 NOT NULL,
  applieddate DATE NOT NULL,
  vrbagencylookupid INT64 NOT NULL,
  sentdate DATE NOT NULL,
  acknowledgeddate DATE NOT NULL,
  rejectiondate DATE NOT NULL,
  vrbrejectlookupid INT64 NOT NULL,
  removeddate DATE NOT NULL,
  vrbremovallookupid INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  insert_date DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL
)
;