## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_InvoicePayment.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.InvoicePayment
(
  invoicenumber INT64,
  invoiceamount NUMERIC(31, 2),
  pbmtollamount NUMERIC(31, 2),
  avitollamount NUMERIC(31, 2),
  tolls NUMERIC(31, 2),
  tollspaid NUMERIC(31, 2),
  tollsadjusted NUMERIC(31, 2),
  firstpaymentdate DATE,
  lastpaymentdate DATE,
  edw_updatedate DATETIME
)
;