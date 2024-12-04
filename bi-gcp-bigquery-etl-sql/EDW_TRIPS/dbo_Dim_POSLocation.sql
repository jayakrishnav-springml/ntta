## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_POSLocation.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Dim_POSLocation
(
  posid INT64 NOT NULL,
  posname STRING NOT NULL,
  poscode STRING NOT NULL,
  posdesc STRING,
  address1 STRING,
  city STRING,
  state STRING,
  zipcode STRING,
  locationtype STRING,
  edw_updatedate TIMESTAMP NOT NULL
)
CLUSTER BY posid
;