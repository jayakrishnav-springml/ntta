## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_Plaza_GIS_Data.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Plaza_GIS_Data
(
  plazaid INT64 NOT NULL,
  corridor STRING NOT NULL,
  roadwayname STRING NOT NULL,
  roadwaytype STRING NOT NULL,
  roadwaydesc STRING NOT NULL,
  status INT64 NOT NULL,
  name STRING NOT NULL,
  ritename STRING NOT NULL,
  type STRING NOT NULL,
  tolledlanes INT64 NOT NULL,
  xcoord NUMERIC(37, 8) NOT NULL,
  ycoord NUMERIC(37, 8) NOT NULL,
  postcode INT64 NOT NULL,
  city STRING NOT NULL,
  county STRING NOT NULL
)
;