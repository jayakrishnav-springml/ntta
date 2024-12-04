## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_PostpaidFleetPayment.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.PostpaidFleetPayment
(
  invoicenumber INT64 NOT NULL,
  custtripid INT64,
  customerid INT64,
  customerstatusid INT64,
  usertypeid INT64,
  planid INT64 NOT NULL,
  paymentdayid INT64,
  txnpaymentdate DATETIME,
  invoiceid INT64 NOT NULL,
  accountstatusid INT64 NOT NULL,
  apptxntypeid INT64 NOT NULL,
  voucherno STRING,
  subsystemid INT64 NOT NULL,
  paymentmodeid INT64 NOT NULL,
  paymentstatusid INT64 NOT NULL,
  refpaymentstatusid INT64,
  paymentid INT64 NOT NULL,
  overpaymentid INT64,
  refpaymentid INT64,
  isvirtualcheck INT64 NOT NULL,
  channelid INT64 NOT NULL,
  icnid INT64 NOT NULL,
  locationid INT64 NOT NULL,
  reftype STRING NOT NULL,
  reasontext STRING NOT NULL,
  approvedby STRING NOT NULL,
  pmttxntype STRING NOT NULL,
  amountreceived NUMERIC(31, 2) NOT NULL,
  txnamount NUMERIC(31, 2) NOT NULL,
  lineitemamount NUMERIC(31, 2) NOT NULL,
  fnfeespaid INT64 NOT NULL,
  snfeespaid INT64 NOT NULL,
  deleteflag INT64
)
;