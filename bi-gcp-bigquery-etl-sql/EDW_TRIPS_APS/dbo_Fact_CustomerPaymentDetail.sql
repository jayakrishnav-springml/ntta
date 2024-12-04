## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_CustomerPaymentDetail.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_CustomerPaymentDetail
(
  customerpaymentdetailid INT64 NOT NULL,
  paymentlineitemid INT64 NOT NULL,
  paymentid INT64 NOT NULL,
  adjlineitemid INT64 NOT NULL,
  adjustmentid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  customerpaymenttypeid INT64,
  apptxntypeid INT64 NOT NULL,
  customerpaymentlevelid INT64 NOT NULL,
  paymentdayid INT64 NOT NULL,
  channelid INT64 NOT NULL,
  paymentmodeid INT64 NOT NULL,
  paymentstatusid INT64 NOT NULL,
  refpaymentid INT64,
  refpaymentstatusid INT64,
  drcrflag STRING,
  lineitemamount NUMERIC(31, 2),
  deleteflag INT64 NOT NULL,
  paymentdate DATETIME,
  edw_update_date DATETIME NOT NULL
)
cluster by customerpaymentdetailid
;