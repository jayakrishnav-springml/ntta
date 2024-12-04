## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_TP_CustomerTripStatusTracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_TP_CustomerTripStatusTracker
(
  statustrackerid INT64 NOT NULL,
  custtripid INT64,
  tptripid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  vehiclenumber STRING,
  vehiclestate STRING,
  vehicleclass STRING,
  reasoncode STRING,
  reasondesc STRING,
  tripstageid INT64 NOT NULL,
  tripstatusid INT64 NOT NULL,
  tripstatusdate DATETIME,
  platetype STRING,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by statustrackerid
;