## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_AppTxnTypes.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_AppTxnTypes
(
  apptxntypeid INT64 NOT NULL,
  apptxntypecode STRING ,
  apptxntypedesc STRING,
  effected_balancetype_positive STRING,
  effected_balancetype_negative STRING,
  main_balance_type STRING,
  txntype_categoryid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
;