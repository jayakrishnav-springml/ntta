## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Utility_Time_Zone_Offset_OLD.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.Time_Zone_Offset_OLD
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