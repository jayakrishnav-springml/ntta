## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_TransactionPayment.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.TransactionPayment
(
  invoicenumber INT64 NOT NULL,
  invoiceid INT64,
  citationid INT64,
  paymentid INT64 NOT NULL,
  overpaymentid INT64,
  customerid INT64 NOT NULL,
  customerstatusid INT64,
  usertypeid INT64,
  planid INT64 NOT NULL,
  paymentdayid INT64,
  txnpaymentdate DATETIME,
  paymentmodeid INT64 NOT NULL,
  paymentstatusid INT64 NOT NULL,
  refpaymentid INT64,
  refpaymentstatusid INT64,
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
  lineitemamount BIGNUMERIC(44, 6),
  amountreceived NUMERIC(31, 2),
  deleteflag INT64
)
;