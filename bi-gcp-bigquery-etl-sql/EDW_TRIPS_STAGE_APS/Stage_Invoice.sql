## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_Invoice.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.Invoice
(
  invoicenumber INT64,
  firstinvoiceid INT64 NOT NULL,
  currentinvoiceid INT64 NOT NULL,
  customerid INT64,
  migratedflag INT64 NOT NULL,
  agestageid INT64,
  collectionstatusid INT64 NOT NULL,
  currmbsid INT64 NOT NULL,
  vehicleid INT64,
  zipcashdate DATE,
  firstnoticedate DATE,
  secondnoticedate DATE,
  thirdnoticedate DATE,
  legalactionpendingdate DATE,
  citationdate DATE,
  duedate DATE,
  currmbsgenerateddate DATE NOT NULL,
  firstpaymentdate DATE,
  lastpaymentdate DATE,
  firstfeepaymentdate DATETIME,
  lastfeepaymentdate DATETIME,
  invoicestatusid INT64,
  txncnt INT64,
  invoiceamount NUMERIC(31, 2),
  pbmtollamount NUMERIC(31, 2),
  avitollamount NUMERIC(31, 2),
  premiumamount NUMERIC(31, 2),
  tolls NUMERIC(31, 2),
  fnfees NUMERIC(31, 2),
  snfees NUMERIC(31, 2),
  tollspaid NUMERIC(31, 2),
  fnfeespaid NUMERIC(31, 2),
  snfeespaid NUMERIC(31, 2),
  tollsadjusted NUMERIC(31, 2),
  fnfeesadjusted NUMERIC(31, 2),
  snfeesadjusted NUMERIC(31, 2),
  edw_update_date TIMESTAMP NOT NULL,
  invoicestatus STRING
)
;