## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_InvoiceAgingSnapshot.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_InvoiceAgingSnapshot
(
  snapshotdate DATE,
  snapshotmonthid INT64 NOT NULL,
  citationid INT64 NOT NULL,
  customerid INT64,
  agestageid INT64,
  citationstageid INT64,
  laneid INT64 NOT NULL,
  tptripid INT64 NOT NULL,
  invoicenumber INT64,
  currentinvoiceflag INT64,
  writeoffflag INT64 NOT NULL,
  deleteflag INT64 NOT NULL,
  transactiondate DATE,
  invoicedate DATE,
  posteddate DATE,
  firstnoticefeedate DATE,
  secondnoticefeedate DATE,
  writeoffdate DATE,
  tollsdue NUMERIC(31, 2),
  firstnoticefees BIGNUMERIC(44, 6),
  secondnoticefees BIGNUMERIC(44, 6),
  outstandingamount NUMERIC(31, 2),
  fnfeesoutstandingamount BIGNUMERIC(44, 6),
  snfeesoutstandingamount BIGNUMERIC(44, 6),
  writeoffamount NUMERIC(31, 2),
  txndate DATE,
  edw_updatedate DATETIME NOT NULL
)
;