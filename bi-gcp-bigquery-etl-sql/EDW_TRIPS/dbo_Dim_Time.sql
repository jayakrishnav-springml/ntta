## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_Time.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Dim_Time
(
  timeid INT64 NOT NULL,
  hour STRING NOT NULL,
  minute STRING NOT NULL,
  second STRING NOT NULL,
  `12_hour` STRING NOT NULL,
  am_pm STRING NOT NULL,
  `5_minute` STRING NOT NULL,
  `10_minute` STRING NOT NULL,
  `15_minute` STRING NOT NULL,
  `30_minute` STRING NOT NULL,
  lastmodified DATETIME NOT NULL
)
cluster by timeid
;