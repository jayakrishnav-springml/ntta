## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Plaza_GIS_Data.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Plaza_GIS_Data
(
  plazaid INT64 NOT NULL,
  plazalatitude BIGNUMERIC(50, 12) NOT NULL,
  plazalongitude BIGNUMERIC(50, 12) NOT NULL,
  zipcode INT64 NOT NULL,
  county STRING NOT NULL
)
cluster by plazaid
;