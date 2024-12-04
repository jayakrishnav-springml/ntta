CREATE TABLE IF NOT EXISTS EDW_TRIPS.Dim_CitationStatus
(
  citationstatusid INT64 NOT NULL,
  citationstatuscode STRING NOT NULL,
  citationstatusdescription STRING,
  parentstatusid INT64,
  activeflag INT64 NOT NULL,
  detaileddesc STRING,
  createddate DATETIME,
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)
CLUSTER BY citationstatusid
;
