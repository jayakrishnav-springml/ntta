-- Translation time: 2024-07-11T07:10:16.441155Z
-- Translation job ID: 01f97d19-b914-463a-8c9e-73c23536d6e1
-- Source: gs://ntta-gcp-poc-source-code-scripts/transpiled_ddl_tmp/ITEM_90_NEW_APS/Stage.MigratedInvoice.dsql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.MigratedInvoice
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
  thirdnoticedate_ri DATETIME,
  citationdate_ri DATETIME,
  legalactionpendingdate_ri DATETIME,
  duedate_ri DATE NOT NULL,
  currmbsgenerateddate_ri STRING NOT NULL,
  firstpaymentdatepriortozc_ri DATE,
  lastpaymentdatepriortozc_ri DATE,
  firstpaymentdateafterzc_ri DATE,
  lastpaymentdateafterzc_ri DATE
)
;
