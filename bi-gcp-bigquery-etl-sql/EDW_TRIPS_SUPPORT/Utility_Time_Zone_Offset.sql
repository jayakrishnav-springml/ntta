## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Utility_Time_Zone_Offset.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Time_Zone_Offset
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
;