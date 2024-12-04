## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_CustomerPaymentDetail.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.CustomerPaymentDetail
(
  paymentlineitemid INT64 NOT NULL,
  paymentid INT64 NOT NULL,
  customerid INT64,
  planid INT64 NOT NULL,
  customerplandesc STRING,
  customerpaymenttype STRING NOT NULL,
  apptxntypeid INT64,
  apptxntypecode STRING,
  apptxntypedesc STRING,
  customerpaymentlevelid INT64 NOT NULL,
  lineitemamount NUMERIC(31, 2),
  paymentdate DATETIME,
  channelid INT64,
  paymentchannelname STRING,
  paymentmodeid INT64 NOT NULL,
  paymentmodecode STRING,
  paymentstatusid INT64 NOT NULL,
  paymentstatuscode STRING,
  refpaymentid INT64,
  refpaymentstatusid INT64,
  deleteflag INT64,
  edw_update_date TIMESTAMP NOT NULL
) CLUSTER BY paymentlineitemid
;