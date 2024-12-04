## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TER_VehicleBanRequest.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TER_VehicleBanRequest
(
  vehiclebanrequestid INT64 NOT NULL,
  fileid INT64,
  vehiclenumber STRING,
  vehiclestate STRING,
  vehicleyear INT64,
  vehiclemake STRING,
  vehiclemodel STRING,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  vehiclebanid INT64,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
vehiclebanrequestid
;