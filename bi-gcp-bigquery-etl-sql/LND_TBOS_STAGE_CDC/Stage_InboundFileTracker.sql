## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_InboundFileTracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.EIP_InboundFileTracker
(
  inboundfileid INT64 NOT NULL,
  agencycode STRING NOT NULL,
  filename STRING NOT NULL,
  filepath STRING NOT NULL,
  servicename STRING NOT NULL,
  processcode INT64,
  processtype STRING,
  processdate DATETIME,
  filetype STRING NOT NULL,
  recordcount INT64,
  acceptcount INT64,
  rejectreason STRING,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateduser STRING,
  updateddate DATETIME,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
inboundfileid
;