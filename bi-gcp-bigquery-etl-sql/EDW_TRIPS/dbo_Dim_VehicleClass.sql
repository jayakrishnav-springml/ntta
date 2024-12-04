## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_VehicleClass.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Dim_VehicleClass
(
  vehicleclassid INT64 NOT NULL,
  axles INT64 NOT NULL,
  vehicleclass STRING NOT NULL,
  vehicleclassdesc STRING NOT NULL,
  vcly_id INT64 NOT NULL,
  edw_updateddate TIMESTAMP NOT NULL
)
cluster by vehicleclassid
;