## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_TripStage.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Dim_TripStage
(
  tripstageid INT64 NOT NULL,
  tripstagecode STRING NOT NULL,
  tripstagedesc STRING NOT NULL,
  parentstageid INT64 NOT NULL,
  updateddate TIMESTAMP NOT NULL,
  lnd_updatedate TIMESTAMP NOT NULL,
  edw_updatedate TIMESTAMP NOT NULL
)
cluster by tripstageid
;