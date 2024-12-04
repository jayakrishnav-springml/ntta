## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TP_FileTracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_TP_FileTracker
(
  fileid INT64 NOT NULL,
  filename STRING,
  filetype INT64,
  processstatus INT64,
  recordcount INT64,
  processedcount INT64,
  processeddate DATETIME,
  source STRING,
  destination STRING,
  requestsource STRING,
  businessdate DATETIME,
  failedcount INT64,
  responsecode STRING,
  rejectcode STRING,
  rejectreason STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)Cluster by fileid
;