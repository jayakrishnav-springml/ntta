## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_DMVExceptionQueue.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.TollPlus_DMVExceptionQueue
(
  exceptionqueueid INT64 NOT NULL,
  status STRING NOT NULL,
  exceptiontype STRING NOT NULL,
  exceptionraisedby STRING NOT NULL,
  exceptionraiseddate DATETIME NOT NULL,
  exceptionresolveduser STRING,
  exceptionresolveddate DATETIME,
  comments STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY exceptionqueueid
;