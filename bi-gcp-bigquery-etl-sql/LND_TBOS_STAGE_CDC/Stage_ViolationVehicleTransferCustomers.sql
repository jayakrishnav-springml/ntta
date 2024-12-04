## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ViolationVehicleTransferCustomers.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.TollPlus_ViolationVehicleTransferCustomers
(
  vtncustid INT64 NOT NULL,
  customerid INT64,
  vehiclenumber STRING,
  vehiclestate STRING,
  platetype STRING,
  effectivedate DATETIME,
  customerfullname STRING,
  docno STRING,
  nonliabilityreasonid INT64,
  normalizedvehiclenumber STRING,
  isvalid INT64,
  comments STRING,
  documentpath STRING,
  filepathconfigid INT64,
  status STRING,
  requesteddate DATETIME,
  processeddate DATETIME,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY vtncustid
;