## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_LANE_GIS_DATA.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Lane_Gis_Data
(
  lane_id INT64 NOT NULL,
  status STRING NOT NULL,
  lane_name STRING NOT NULL,
  toll_location STRING NOT NULL,
  description STRING NOT NULL,
  type STRING NOT NULL,
  plaza_id INT64,
  id INT64 NOT NULL,
  source STRING NOT NULL,
  lane_direction STRING,
  postcode INT64 NOT NULL,
  pc_name STRING NOT NULL,
  county STRING NOT NULL,
  longitude NUMERIC(37, 8) NOT NULL,
  latitude NUMERIC(37, 8) NOT NULL
)
cluster by lane_id
;
