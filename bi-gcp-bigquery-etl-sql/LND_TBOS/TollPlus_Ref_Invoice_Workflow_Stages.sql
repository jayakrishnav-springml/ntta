## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_Ref_Invoice_Workflow_Stages.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_Ref_Invoice_Workflow_Stages
(
  stageid INT64 NOT NULL,
  stagename STRING,
  stageorder INT64,
  stepscount INT64,
  isactive INT64,
  stagecode STRING,
  agingperiod INT64,
  graceperiod INT64,
  waiveallfees INT64 NOT NULL,
  applyavirate INT64 NOT NULL,
  icnid INT64,
  channelid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by stageid
;