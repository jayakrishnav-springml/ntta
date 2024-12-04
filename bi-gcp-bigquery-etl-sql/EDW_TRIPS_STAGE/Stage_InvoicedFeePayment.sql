## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_InvoicedFeePayment.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.InvoicedFeePayment
(
  invoicenumber INT64 NOT NULL,
  invoiceid INT64,
  invoicechargeid INT64 NOT NULL,
  citationid INT64,
  paymentid INT64 NOT NULL,
  overpaymentid INT64,
  customerid INT64,
  customerstatusid INT64,
  usertypeid INT64,
  planid INT64 NOT NULL,
  paymentdayid INT64,
  txnpaymentdate DATETIME,
  paymentmodeid INT64 NOT NULL,
  paymentstatusid INT64 NOT NULL,
  refpaymentstatusid INT64,
  refpaymentid INT64,
  voucherno STRING,
  reftype STRING,
  accountstatusid INT64 NOT NULL,
  channelid INT64,
  locationid INT64,
  icnid INT64,
  isvirtualcheck INT64,
  pmttxntype STRING,
  subsystemid INT64 NOT NULL,
  apptxntypeid INT64 NOT NULL,
  approvedby STRING,
  reasontext STRING,
  txnamount NUMERIC(31, 2) NOT NULL,
  lineitemamount NUMERIC(31, 2) NOT NULL,
  amountreceived NUMERIC(30, 1) NOT NULL,
  fnfeespaid BIGNUMERIC(51, 13),
  snfeespaid BIGNUMERIC(51, 13),
  deleteflag INT64
) 
;