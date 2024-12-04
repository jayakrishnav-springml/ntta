## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Utility_ProcessLog.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.ProcessLog
(
  logdate DATETIME NOT NULL,
  logsource STRING NOT NULL,
  logmessage STRING NOT NULL,
  logtype STRING NOT NULL,
  row_count INT64,
  proctime STRING,
  querytime STRING,
  proctimeinsec NUMERIC(32, 3),
  querytimeinsec NUMERIC(32, 3),
  procstartdate DATETIME,
  querysubmitdate DATETIME,
  queryenddate DATETIME,
  sessionid STRING,
  queryid STRING,
  query STRING,
  resourceclass STRING
)
cluster by LogDate
;