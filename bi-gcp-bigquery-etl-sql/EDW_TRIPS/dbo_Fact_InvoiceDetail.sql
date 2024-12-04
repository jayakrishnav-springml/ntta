## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_InvoiceDetail.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Fact_InvoiceDetail
(
  invoicenumber INT64,
  citationid INT64,
  tptripid INT64 NOT NULL,
  customerid INT64,
  laneid INT64 NOT NULL,
  agestageid INT64,
  paymentstatusid INT64,
  tripstageid INT64,
  tripstatusid INT64 NOT NULL,
  transactiontypeid INT64,
  transactionpostingtypeid INT64 NOT NULL,
  invoicestatusid INT64,
  currentinvflag INT64 NOT NULL,
  writeoffflag INT64,
  hvflag INT64 NOT NULL,
  ppflag INT64 NOT NULL,
  invoicedbadaddr INT64 NOT NULL,
  txndate DATE,
  posteddate DATE,
  zcinvoicedate DATE,
  fnfeesdate DATE,
  snfeesdate DATE,
  writeoffdate DATE,
  txntype STRING,
  outstandingamount NUMERIC(31, 2) NOT NULL,
  pbmtollamount NUMERIC(31, 2),
  avitollamount NUMERIC(31, 2),
  tolls NUMERIC(31, 2),
  tollspaid NUMERIC(31, 2),
  fnfees BIGNUMERIC(44, 6),
  snfees BIGNUMERIC(44, 6),
  fnfeespaid BIGNUMERIC(44, 6),
  snfeespaid BIGNUMERIC(44, 6),
  fnfeesoutstandingamount BIGNUMERIC(44, 6),
  snfeesoutstandingamount BIGNUMERIC(44, 6),
  writeoffamount NUMERIC(31, 2),
  deleteflag INT64,
  edw_updatedate DATETIME NOT NULL
)
PARTITION BY
  DATE_TRUNC(txndate, MONTH)
  OPTIONS ( require_partition_filter = TRUE)
;