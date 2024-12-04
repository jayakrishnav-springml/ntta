## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Temp_Fact_InvoiceAgingSnapshot.sql
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
  vehicleid INT64,
  tptripid INT64 NOT NULL,
  invoicestatusid INT64,
  invoicenumber INT64,
  transactiondate DATE,
  invoicedate DATE,
  posteddate DATE,
  duedate DATE,
  firstnoticefeedate DATE,
  secondnoticefeedate DATE,
  totaltransactions INT64,
  tollsdue NUMERIC(31, 2),
  firstnoticefees NUMERIC(31, 2),
  secondnoticefees NUMERIC(31, 2),
  outstandingamount NUMERIC(31, 2),
  outstandingfees NUMERIC(31, 2),
  currentinvoiceflag INT64,
  txndate DATE,
  fnfeesdate DATE,
  snfeesdate DATE,
  totaltxns INT64
)
;