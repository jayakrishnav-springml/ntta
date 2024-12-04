## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Gl_Transactions.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.Finance_Gl_Transactions
(
  gl_txnid INT64 NOT NULL,
  postingdate DATETIME NOT NULL,
  postingdate_yyyymm INT64 NOT NULL,
  customerid INT64 NOT NULL,
  txntypeid INT64 NOT NULL,
  businessprocessid INT64 NOT NULL,
  linkid INT64 NOT NULL,
  linksourcename STRING,
  txndate DATETIME NOT NULL,
  txnamount NUMERIC(31, 2) NOT NULL,
  iscontra INT64,
  description STRING,
  requestid STRING,
  businessunitid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
gl_txnid
;