## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_PLAZA_GIS_DATA.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Plaza_Gis_Data
(
  corridor STRING NOT NULL,
  roadway_name STRING NOT NULL,
  roadway_type STRING NOT NULL,
  roadway_desc STRING NOT NULL,
  status INT64 NOT NULL,
  name STRING NOT NULL,
  rite_name STRING NOT NULL,
  type STRING NOT NULL,
  tolled_lanes INT64 NOT NULL,
  x_coord NUMERIC(37, 8) NOT NULL,
  y_coord NUMERIC(37, 8) NOT NULL,
  postcode INT64 NOT NULL,
  county STRING NOT NULL
)
;
