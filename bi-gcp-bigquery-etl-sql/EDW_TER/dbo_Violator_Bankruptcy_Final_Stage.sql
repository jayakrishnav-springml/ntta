
CREATE TABLE IF NOT EXISTS EDW_TER.Violator_Bankruptcy_Final_Stage
(
  violatorid FLOAT64 NOT NULL,
  vidseq INT64 NOT NULL,
  bankruptcyinstancenbr INT64 NOT NULL,
  lastname STRING,
  firstname STRING,
  lastname2 STRING,
  firstname2 STRING,
  licenseplate STRING,
  casenumber STRING,
  datenotified DATETIME NOT NULL,
  filingdate DATETIME NOT NULL,
  conversiondate DATETIME NOT NULL,
  excusedamount NUMERIC(33, 4),
  collectableamount NUMERIC(33, 4),
  phonenumber STRING,
  dischargedismissedid INT64 NOT NULL,
  discharge_dismissed_date DATETIME NOT NULL,
  assets INT64 NOT NULL,
  collectionaccounts INT64 NOT NULL,
  lawfirm STRING,
  attorneyname STRING,
  claimfilled INT64 NOT NULL,
  comments STRING,
  filingstatusid INT64 NOT NULL,
  insertdate DATETIME NOT NULL,
  insertbyuser STRING NOT NULL,
  lastupdatedate DATETIME,
  lastupdatebyuser STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by vidseq
;