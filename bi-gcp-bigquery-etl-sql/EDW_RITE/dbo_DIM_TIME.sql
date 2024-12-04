## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_TIME.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Time
(
  time_id INT64 NOT NULL,
  hour STRING NOT NULL,
  `12_hour` STRING NOT NULL,
  am_pm STRING NOT NULL,
  `30_minute` STRING NOT NULL,
  `15_minute` STRING NOT NULL,
  `10_minute` STRING NOT NULL,
  `5_minute` STRING NOT NULL,
  minute STRING NOT NULL,
  second STRING NOT NULL
)
cluster by time_id
;
