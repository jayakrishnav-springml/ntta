## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_Vehicle_Old.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Dim_Vehicle_Old
(
  vehicleid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  licenseplatenumber STRING,
  licenseplatestate STRING NOT NULL,
  licenseplatecountry STRING NOT NULL,
  vehicleyear INT64,
  vehiclemake STRING,
  vehiclemodel STRING,
  vehiclecolor STRING,
  vehiclestartdate DATETIME NOT NULL,
  vehicleenddate DATETIME NOT NULL,
  vehiclestatusid INT64 NOT NULL,
  vehiclestatuscode STRING NOT NULL,
  vehiclestatusdesc STRING NOT NULL,
  vehicleclassid INT64 NOT NULL,
  docno STRING,
  tagid STRING NOT NULL,
  county STRING,
  vin STRING,
  contractualtypeid INT64 NOT NULL,
  contractualtypecode STRING NOT NULL,
  contractualtypedesc STRING NOT NULL,
  exemptedflag INT64 NOT NULL,
  hvflag INT64 NOT NULL,
  updateddate DATETIME NOT NULL,
  lnd_updatedate DATETIME NOT NULL,
  edw_updatedate DATETIME
)
cluster by vehicleid
;