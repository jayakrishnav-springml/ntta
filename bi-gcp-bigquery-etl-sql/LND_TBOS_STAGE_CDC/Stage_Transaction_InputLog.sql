## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Transaction_InputLog.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.MIR_Transaction_InputLog
(
  txninputlogid INT64 NOT NULL,
  agencycode STRING NOT NULL,
  agencytxnid STRING NOT NULL,
  agencytimestamp INT64 NOT NULL,
  clentsenddate DATETIME,
  responsecode STRING NOT NULL,
  rejectcode INT64 NOT NULL,
  rejectreason STRING,
  eiptxnid INT64 NOT NULL,
  transactiondate DATE,
  transactiontime INT64,
  plazaid STRING,
  laneid STRING,
  daynighttwilight INT64,
  referencetrackerid INT64,
  subscriberid STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)Cluster by txninputlogid
;