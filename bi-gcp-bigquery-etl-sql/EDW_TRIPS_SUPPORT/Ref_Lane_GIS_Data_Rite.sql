## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_Lane_GIS_Data.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Lane_GIS_Data
(
  laneid INT64 NOT NULL,
  status STRING NOT NULL,
  lanename STRING NOT NULL,
  tolllocation STRING NOT NULL,
  description STRING NOT NULL,
  type STRING NOT NULL,
  plazaid INT64,
  id INT64 NOT NULL,
  source STRING NOT NULL,
  lanedirection STRING,
  zipcode INT64 NOT NULL,
  pcname STRING NOT NULL,
  county STRING NOT NULL,
  latitude NUMERIC(37, 8) NOT NULL,
  longitude NUMERIC(37, 8) NOT NULL,
  plazasortorder INT64 NOT NULL
)
cluster by laneid
;