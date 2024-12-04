## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_MigratedInvoice.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.MigratedInvoice
(
  rn_max INT64,
  invoicenumber STRING,
  invoiceid INT64 NOT NULL,
  customerid INT64,
  agestageid INT64,
  collectionstatus INT64,
  vehicleid INT64,
  invoicedate DATETIME,
  duedate DATETIME,
  adjustedamount NUMERIC(31, 2),
  invoicestatus STRING,
  lnd_updatetype STRING,
  agestageid_ri INT64 NOT NULL,
  zipcashdate_ri DATE NOT NULL,
  firstnoticedate_ri DATE,
  secondnoticedate_ri DATE,
  thirdnoticedate_ri TIMESTAMP,
  citationdate_ri DATETIME,
  legalactionpendingdate_ri TIMESTAMP,
  duedate_ri DATE NOT NULL,
  currmbsgenerateddate_ri STRING NOT NULL,
  firstpaymentdate_ri DATE,
  lastpaymentdate_ri DATE
)
;