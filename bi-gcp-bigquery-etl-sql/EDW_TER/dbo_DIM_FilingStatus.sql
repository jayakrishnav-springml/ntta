CREATE TABLE IF NOT EXISTS EDW_TER.Dim_FilingStatus
(
  filingstatusid INT64 NOT NULL,
  filingstatus STRING NOT NULL,
  insert_datetime DATETIME NOT NULL
)
CLUSTER BY filingstatusid
;
