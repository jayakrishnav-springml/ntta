## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_NonMigInvoice.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.NonMigInvoice
(
  rn_max INT64,
  invoicenumber STRING,
  invoiceid INT64 NOT NULL,
  customerid INT64,
  agestageid INT64,
  vehicleid INT64,
  collectionstatus INT64,
  invoicestatus STRING,
  invoicedate DATETIME,
  lnd_updatetype STRING
)
;