## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TpFileTracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_TpFileTracker
(
  fileid INT64 NOT NULL,
  filename STRING NOT NULL,
  filetype STRING NOT NULL,
  filesource STRING,
  destination STRING,
  requestsource STRING,
  filedirection STRING NOT NULL,
  filereceivedate DATETIME,
  filegenerateddate DATETIME,
  businessdate DATETIME,
  fileprocessed STRING,
  processeddate DATETIME,
  processedcount INT64,
  filestatus INT64,
  totalcount INT64,
  recordcount INT64,
  failedcount INT64,
  nooftxns INT64,
  filesequencenumber STRING,
  parentfileid STRING,
  retryattempts INT64,
  module STRING,
  remarks STRING,
  sourcepkid INT64,
  sourcename STRING,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)Cluster by fileid
;