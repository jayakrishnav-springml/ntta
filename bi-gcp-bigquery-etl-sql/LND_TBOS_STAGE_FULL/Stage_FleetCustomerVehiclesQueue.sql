## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_FleetCustomerVehiclesQueue.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_FleetCustomerVehiclesQueue
(
  queueid INT64 NOT NULL,
  parentfileid INT64,
  recordsequencenumber STRING,
  vehiclenumber STRING,
  vehiclestate STRING,
  startdate DATETIME,
  enddate DATETIME,
  vin STRING,
  vehiclestatus STRING,
  make STRING,
  model STRING,
  color STRING,
  isprocessed INT64,
  replaceerrorcode STRING,
  recordcode STRING,
  status STRING,
  zipcashdue NUMERIC(31, 2),
  responsefileid INT64,
  calltype INT64,
  otherinfo STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
queueid
;