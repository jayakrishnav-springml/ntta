## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_VehicleTag_Old.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Dim_VehicleTag_Old
(
  vehicletagid INT64 NOT NULL,
  custtagid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  tagid STRING NOT NULL,
  vehicleid INT64 NOT NULL,
  tagtype STRING NOT NULL,
  tagstatus STRING NOT NULL,
  tagagency STRING,
  tagmounting STRING,
  tagspeciality STRING,
  tagstatusdate DATE NOT NULL,
  tagstartdate DATE NOT NULL,
  tagenddate DATE NOT NULL,
  nonrevenueflag INT64,
  updateddate DATETIME NOT NULL,
  lnd_updatedate DATETIME NOT NULL,
  edw_updatedate DATETIME
)
cluster by vehicletagid
;