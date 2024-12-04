CREATE TABLE IF NOT EXISTS EDW_TER.Vrb_Stage
(
  vrbid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  activeflag INT64 NOT NULL,
  vrbstatuslookupid INT64 NOT NULL,
  applieddate DATETIME NOT NULL,
  vrbagencylookupid INT64 NOT NULL,
  sentdate DATETIME NOT NULL,
  acknowledgeddate DATETIME NOT NULL,
  rejectiondate DATETIME NOT NULL,
  vrbrejectlookupid INT64,
  removeddate DATETIME NOT NULL,
  vrbremovallookupid INT64,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by vrbid
;