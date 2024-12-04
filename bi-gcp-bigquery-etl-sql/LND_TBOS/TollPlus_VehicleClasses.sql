## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_VehicleClasses.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_VehicleClasses
(
  vehicleclassid INT64 NOT NULL,
  vehicleclasscode STRING NOT NULL,
  name STRING,
  vehicleclassdesc STRING,
  thresholdamount NUMERIC(31, 2),
  tagdeposit NUMERIC(31, 2),
  starteffectivedate DATETIME,
  endeffectivedate DATETIME,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by vehicleclassid
;