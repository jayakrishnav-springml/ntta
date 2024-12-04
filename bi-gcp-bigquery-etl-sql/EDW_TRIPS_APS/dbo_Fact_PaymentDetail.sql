## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_PaymentDetail.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_PaymentDetail
(
  invoicenumber INT64 NOT NULL,
  invoiceid INT64,
  tptripid INT64,
  citationid INT64,
  paymentid INT64 NOT NULL,
  overpaymentid INT64,
  paymentdayid INT64,
  paymentmodeid INT64 NOT NULL,
  paymentstatusid INT64 NOT NULL,
  refpaymentstatusid INT64,
  apptxntypeid INT64 NOT NULL,
  laneid INT64,
  customerid INT64,
  customerstatusid INT64,
  accounttypeid INT64,
  accountstatusid INT64 NOT NULL,
  planid INT64 NOT NULL,
  refpaymentid INT64,
  voucherno STRING,
  channelid INT64,
  posid INT64 NOT NULL,
  icnid INT64,
  isvirtualcheck INT64,
  pmttxntype STRING,
  subsystemid INT64 NOT NULL,
  txnpaymentdate DATETIME,
  approvedby STRING,
  reasontext STRING,
  txnamount NUMERIC(31, 2) NOT NULL,
  lineitemamount BIGNUMERIC(44, 6),
  amountreceived BIGNUMERIC(40, 2),
  fnfeespaid BIGNUMERIC(49, 11),
  snfeespaid BIGNUMERIC(49, 11),
  deleteflag INT64 NOT NULL,
  edw_update_date DATETIME NOT NULL
)
;