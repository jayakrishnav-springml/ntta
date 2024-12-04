## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TP_Customer_Vehicles.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.TollPlus_TP_Customer_Vehicles
(
  vehicleid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  vehiclenumber STRING,
  vehiclecountry STRING NOT NULL,
  vehiclestate STRING NOT NULL,
  year INT64,
  make STRING,
  model STRING,
  color STRING,
  starteffectivedate DATETIME NOT NULL,
  endeffectivedate DATETIME NOT NULL,
  vehiclestatusid INT64 NOT NULL,
  vehicleclasscode STRING NOT NULL,
  vin STRING,
  isprotected INT64,
  isexempted INT64,
  istempnumber INT64,
  tagid STRING,
  contractualtypeid INT64,
  platetype STRING,
  vehicleshape STRING,
  fuelefficiency STRING,
  ishamradiooperator INT64,
  istrailer INT64,
  licenseplateimagepath STRING,
  departmentname STRING,
  excessivevtolls INT64,
  isinhv INT64 NOT NULL,
  isvrh INT64 NOT NULL,
  docno STRING,
  vehiclebodyvin STRING,
  county STRING,
  temp_source STRING,
  temp_pk INT64,
  temp_key INT64,
  channelid INT64,
  icnid INT64,
  isvtollenabled INT64 NOT NULL,
  filepathconfigurationid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY VehicleID
;