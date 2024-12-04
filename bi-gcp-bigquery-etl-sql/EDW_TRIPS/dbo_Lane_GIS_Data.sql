## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Lane_GIS_Data.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Lane_GIS_Data
(
  laneid INT64 NOT NULL,
  plazaid INT64 NOT NULL,
  lanename STRING NOT NULL,
  direction STRING,
  latitude BIGNUMERIC(50, 12),
  longitude BIGNUMERIC(50, 12),
  zipcode INT64,
  county STRING,
  mileage NUMERIC(31, 2) NOT NULL,
  active INT64 NOT NULL,
  plazasortorder INT64
)
cluster by laneid
;