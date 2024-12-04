## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/TollPlus_Collections_Inbound.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TollPlus_Collections_Inbound
(
  collinbound_txnid INT64 NOT NULL,
  fileid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  transactiondate DATETIME NOT NULL,
  firstname STRING,
  middlename STRING,
  lastname STRING,
  transactiontype STRING,
  previousbalance NUMERIC(31, 2),
  transactionamount NUMERIC(31, 2) NOT NULL,
  currentbalance NUMERIC(31, 2),
  status INT64 NOT NULL,
  notes STRING,
  paymenttype STRING,
  errors STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
cluster by collinbound_txnid
;