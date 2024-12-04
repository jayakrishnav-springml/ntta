## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TP_Bankruptcy_Filing.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_TP_Bankruptcy_Filing
(
  bankruptcyfid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  startdate DATETIME NOT NULL,
  petitionnumber STRING NOT NULL,
  bankruptcystatusid INT64 NOT NULL,
  bankruptcytypeid INT64 NOT NULL,
  decisiondate DATETIME,
  icnid INT64,
  channelid INT64,
  ismigrated INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY BankruptcyFID
;