## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_VehicleBan.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_VehicleBan
(
  vehiclebanid INT64 NOT NULL,
  hvid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  vehicleid INT64 NOT NULL,
  vehiclebanstatusid INT64 NOT NULL,
  vehiclebanremovalstatusid INT64 NOT NULL,
  activeflag INT64 NOT NULL,
  vbrequesteddayid INT64,
  vbapplieddayid INT64,
  removeddate DATETIME,
  earliestvehiclebanlettermaileddate DATE,
  earliestvehiclebanletterdelivereddate DATE,
  latestvehiclebanlettermaileddate DATE,
  latestvehiclebanletterdelivereddate DATE,
  edw_updatedate DATETIME NOT NULL
)
cluster by hvid
;