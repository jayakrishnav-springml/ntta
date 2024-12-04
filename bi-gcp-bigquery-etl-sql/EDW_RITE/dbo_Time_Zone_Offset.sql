## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_Time_Zone_Offset.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Time_Zone_Offset
(
  yyyy INT64,
  dst_start_date DATETIME,
  dst_end_date DATETIME,
  daylight_weeks INT64,
  source_tz STRING,
  target_tz STRING,
  dst_offset INT64,
  non_dst_offset INT64
)
cluster by dst_start_date
;
