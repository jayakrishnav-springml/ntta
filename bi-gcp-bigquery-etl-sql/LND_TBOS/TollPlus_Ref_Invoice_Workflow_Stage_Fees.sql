## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_Ref_Invoice_Workflow_Stage_Fees.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_Ref_Invoice_Workflow_Stage_Fees
(
  stagefeeid INT64 NOT NULL,
  stageid INT64,
  feetypeid INT64 NOT NULL,
  isactive INT64,
  fee_days INT64 NOT NULL,
  appliedfor INT64 NOT NULL,
  iswaivefee INT64 NOT NULL,
  isconsiderfeeformbs INT64 NOT NULL,
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
cluster by stagefeeid
;