## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_DMVRequestTracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_DMVRequestTracker
(
  requesttrackerid INT64 NOT NULL,
  fileid INT64,
  licensenumber STRING,
  receiveddate DATETIME,
  transactiondate DATETIME,
  requestsource STRING,
  requesteduser STRING,
  vehiclestate STRING,
  vehiclecountry STRING,
  expirationyear INT64,
  endeffectivedate DATETIME,
  businessdate DATETIME,
  dmvresponse STRING,
  dmvprovider STRING,
  platetype STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY requesttrackerid
;