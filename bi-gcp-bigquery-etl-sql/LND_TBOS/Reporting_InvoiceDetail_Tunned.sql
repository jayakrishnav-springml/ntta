## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Reporting_InvoiceDetail_Tunned.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.Reporting_InvoiceDetail_Tunned
(
  invoiceid INT64,
  invoicenumber STRING,
  lineitemid INT64,
  agencyid INT64,
  roadway INT64,
  type STRING,
  category STRING,
  invoiceescalationlevel STRING,
  invoicestatus STRING,
  txntype STRING,
  txndate DATETIME,
  posteddate DATETIME,
  invoicedate DATETIME,
  paiddate DATETIME,
  postedamount NUMERIC(31, 2),
  paidamount NUMERIC(31, 2),
  outstandingamount NUMERIC(31, 2),
  citationid INT64,
  tptripid INT64,
  tripstatus INT64,
  receivableindication INT64,
  customerid INT64,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
invoiceid
;