## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_MST_TransactionTypes.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.MIR_MST_TransactionTypes
(
  transactiontypeid INT64 NOT NULL,
  transactiontype STRING NOT NULL,
  transactiontypesource STRING NOT NULL,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by transactiontypeid
;