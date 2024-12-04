-- Translation time: 2024-07-11T07:10:16.441155Z
-- Translation job ID: 01f97d19-b914-463a-8c9e-73c23536d6e1
-- Source: gs://ntta-gcp-poc-source-code-scripts/transpiled_ddl_tmp/ITEM_90_NEW_APS/Stage.InvoicePayment.dsql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.InvoicePayment
(
  invoicenumber INT64,
  excuseddate DATETIME,
  firstpaymentdatepriortozc DATE,
  lastpaymentdatepriortozc DATE,
  firstpaymentdateafterzc DATE,
  lastpaymentdateafterzc DATE,
  paymentchannel STRING,
  pos STRING,
  pbmtollamount NUMERIC(31, 2),
  avitollamount NUMERIC(31, 2),
  tolls NUMERIC(31, 2),
  tollspaid NUMERIC(31, 2),
  tollsadjusted NUMERIC(31, 2),
  edw_updatedate DATETIME
)
;
