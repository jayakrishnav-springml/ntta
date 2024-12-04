## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_Invoice_LineItems.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_CDC.TollPlus_Invoice_LineItems
(
  invlineitemid INT64 NOT NULL,
  invoiceid INT64,
  linkid INT64,
  custtxncategory STRING,
  txntype STRING,
  stmt_literal STRING,
  amount NUMERIC(31, 2),
  subsystem STRING NOT NULL,
  linksourcename STRING,
  txndate DATETIME,
  referenceinvoiceid STRING,
  sourceviolationstatus STRING,
  createddate DATETIME NOT NULL,
  createduser STRING NOT NULL,
  updateddate DATETIME NOT NULL,
  updateduser STRING NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
invlineitemid
;