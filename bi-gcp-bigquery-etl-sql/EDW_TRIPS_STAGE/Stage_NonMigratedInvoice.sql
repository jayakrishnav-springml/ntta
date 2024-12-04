-- Translation time: 2024-07-11T07:10:16.441155Z
-- Translation job ID: 01f97d19-b914-463a-8c9e-73c23536d6e1
-- Source: gs://ntta-gcp-poc-source-code-scripts/transpiled_ddl_tmp/ITEM_90_NEW_APS/Stage.NonMigratedInvoice.dsql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE EDW_TRIPS_STAGE.NonMigratedInvoice
(
  invoicenumber INT64,
  firstinvoiceid INT64 NOT NULL,
  currentinvoiceid INT64 NOT NULL,
  customerid INT64,
  migratedflag INT64 NOT NULL,
  vtollflag INT64 NOT NULL,
  unassignedflag INT64 NOT NULL,
  txnpriortozcflag INT64 NOT NULL,
  agestageid INT64,
  collectionstatusid INT64 NOT NULL,
  currmbsid INT64 NOT NULL,
  vehicleid INT64,
  paymentplanid INT64,
  invoicestatusid INT64,
  edw_invoicestatusid INT64 NOT NULL,
  edw_invoicestatusidafterzc INT64 NOT NULL,
  zipcashdate DATE,
  firstnoticedate DATE,
  secondnoticedate DATE,
  thirdnoticedate DATE,
  legalactionpendingdate DATE,
  citationdate DATE,
  duedate DATE,
  currmbsgenerateddate DATE NOT NULL,
  firstpaymentdatepriortozc DATE,
  lastpaymentdatepriortozc DATE,
  firstpaymentdateafterzc DATE,
  lastpaymentdateafterzc DATE,
  firstfeepaymentdate DATETIME,
  lastfeepaymentdate DATETIME,
  primarycollectionagencydate DATETIME,
  secondarycollectionagencydate DATETIME,
  txncntpriortozc INT64,
  vtolltxncntpriortozc INT64,
  paidtxncntpriortozc INT64,
  excusedtxncntpriortozc INT64,
  txncntafterzc INT64,
  vtolltxncntafterzc INT64,
  paidtxncntafterzc INT64,
  excusedtxncntafterzc INT64,
  txncnt INT64,
  excusedtxncnt INT64,
  unassignedtxncnt INT64,
  vtolltxncnt INT64,
  paidtxncnt INT64,
  nooftimessenttoprimary INT64,
  nooftimessenttosecondary INT64,
  paymentchannel STRING,
  pos STRING,
  primarycollectionagency STRING,
  secondarycollectionagency STRING,
  invoiceamount NUMERIC(31, 2),
  pbmtollamount NUMERIC(31, 2),
  avitollamount NUMERIC(31, 2),
  premiumamount NUMERIC(31, 2),
  vtollamountpriortozc NUMERIC(31, 2),
  vtollamountafterzc BIGNUMERIC(40, 2),
  vtollamount BIGNUMERIC(40, 2),
  excusedamountpriortozc NUMERIC(31, 2),
  excusedamountafterzc BIGNUMERIC(40, 2),
  excusedamount BIGNUMERIC(40, 2),
  tollspriortozc NUMERIC(31, 2),
  tollsafterzc NUMERIC(31, 2),
  tolls NUMERIC(31, 2),
  fnfees NUMERIC(31, 2),
  snfees NUMERIC(31, 2),
  expectedamount NUMERIC(31, 2),
  tollsadjustedpriortozc NUMERIC(31, 2),
  tollsadjustedafterzc NUMERIC(31, 2),
  tollsadjusted NUMERIC(31, 2),
  fnfeesadjusted NUMERIC(31, 2),
  snfeesadjusted NUMERIC(31, 2),
  adjustedamount NUMERIC(31, 2),
  adjustedexpectedtollspriortozc NUMERIC(31, 2),
  adjustedexpectedtollsafterzc NUMERIC(31, 2),
  adjustedexpectedtolls NUMERIC(31, 2),
  adjustedexpectedfnfees NUMERIC(31, 2),
  adjustedexpectedsnfees NUMERIC(31, 2),
  adjustedexpectedamount NUMERIC(31, 2),
  tollspaidpriortozc NUMERIC(31, 2),
  tollspaidafterzc NUMERIC(31, 2),
  tollspaid NUMERIC(31, 2),
  fnfeespaid NUMERIC(31, 2),
  snfeespaid NUMERIC(31, 2),
  paidamount NUMERIC(31, 2),
  tolloutstandingamountpriortozc NUMERIC(31, 2),
  tolloutstandingamountafterzc NUMERIC(31, 2),
  tolloutstandingamount BIGNUMERIC(40, 2),
  fnfeesoutstandingamount NUMERIC(31, 2),
  snfeesoutstandingamount NUMERIC(31, 2),
  outstandingamount BIGNUMERIC(40, 2),
  edw_update_date DATETIME NOT NULL
)
;