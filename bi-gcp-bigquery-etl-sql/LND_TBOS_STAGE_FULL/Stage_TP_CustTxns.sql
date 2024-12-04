## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_TP_CustTxns.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_TP_CustTxns
(
  custtxnid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  linkid INT64 NOT NULL,
  linksourcename STRING,
  txnamount NUMERIC(31, 2) NOT NULL,
  posteddate DATETIME NOT NULL,
  vehicleid INT64 NOT NULL,
  apptxntypecode STRING,
  businessprocesscode STRING,
  stmt_literal STRING,
  custtxncategory STRING,
  previousbalance NUMERIC(31, 2),
  currentbalance NUMERIC(31, 2),
  subsystem STRING,
  locationname STRING,
  balancetype STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY CustTxnID
;