## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_ChartOfAccounts.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.Finance_ChartOfAccounts
(
  surrogate_coaid INT64 NOT NULL,
  chartofaccountid INT64 NOT NULL,
  accountname STRING,
  parentchartofaccountid INT64,
  agcode STRING NOT NULL,
  asgcode STRING NOT NULL,
  lowerbound INT64,
  upperbound INT64,
  status STRING,
  iscontrolaccount STRING,
  normalbalancetype STRING,
  legalaccountid INT64,
  agencycode STRING,
  starteffectivedate DATETIME,
  endeffectivedate DATETIME,
  comments STRING,
  isdeleted INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY chartofaccountid
;