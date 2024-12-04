## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_PLAZA_PLAZA_XREF.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Plaza_Plaza_Xref
(
  segment_id STRING NOT NULL,
  from_facility_id NUMERIC(29),
  from_plaza_id NUMERIC(29),
  from_lane_direction STRING,
  to_facility_id NUMERIC(29) NOT NULL,
  to_plaza_id NUMERIC(29) NOT NULL,
  to_lane_direction STRING,
  min_time INT64 NOT NULL,
  max_time INT64 NOT NULL
)
;
