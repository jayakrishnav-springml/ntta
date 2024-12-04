
CREATE TABLE IF NOT EXISTS EDW_TRIPS.Fact_GL_DailySummary
(
  dailysummaryid INT64 NOT NULL,
  chartofaccountid INT64 NOT NULL,
  businessunitid INT64 NOT NULL,
  beginningbal NUMERIC(31, 2) NOT NULL,
  endingbal NUMERIC(31, 2),
  debittxnamount NUMERIC(31, 2) NOT NULL,
  credittxnamount NUMERIC(31, 2) NOT NULL,
  posteddate DATE,
  jobrundate DATE,
  fiscalyearname STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  deleteflag INT64,
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)
cluster by dailysummaryid
;