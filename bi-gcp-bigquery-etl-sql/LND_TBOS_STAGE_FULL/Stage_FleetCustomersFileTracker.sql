## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_FleetCustomersFileTracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_FleetCustomersFileTracker
(
  trackerid INT64 NOT NULL,
  parentfileid INT64,
  customerid INT64,
  filedirection STRING,
  filetype STRING,
  filename STRING,
  filesequencenumber STRING,
  fileprocesseddate DATETIME,
  isprocessed INT64,
  recordcount INT64,
  processedcount INT64,
  errorcount INT64,
  replaceerrorcode STRING,
  originatingauthority STRING,
  originatingauthorityreference STRING,
  originalfilesequencereference STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
trackerid
;