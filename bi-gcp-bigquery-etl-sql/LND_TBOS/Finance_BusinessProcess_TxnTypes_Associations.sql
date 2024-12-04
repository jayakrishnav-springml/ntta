## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Finance_BusinessProcess_TxnTypes_Associations.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.Finance_BusinessProcess_TxnTypes_Associations
(
  txnassociationid INT64 NOT NULL,
  businessprocessid INT64 NOT NULL,
  txntypeid INT64 NOT NULL,
  txncode STRING,
  chartofaccountid INT64,
  lineitemcode STRING,
  source STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
txnassociationid
;