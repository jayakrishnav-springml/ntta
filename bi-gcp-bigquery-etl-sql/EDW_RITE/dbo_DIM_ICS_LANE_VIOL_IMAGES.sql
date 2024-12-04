## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_ICS_LANE_VIOL_IMAGES.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Ics_Lane_Viol_Images
(
  lane_viol_id NUMERIC(29) NOT NULL,
  image_location STRING,
  image_name_1 STRING,
  image_name_2 STRING,
  image_name_3 STRING,
  image_name_4 STRING,
  image_name_5 STRING,
  image_name_6 STRING
)
cluster by lane_viol_id
;
