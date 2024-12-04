-- Translation time: 2024-07-11T07:10:16.441155Z
-- Translation job ID: 01f97d19-b914-463a-8c9e-73c23536d6e1
-- Source: gs://ntta-gcp-poc-source-code-scripts/transpiled_ddl_tmp/ITEM_90_NEW_APS/stage.DismissedVtollTxn.dsql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.DismissedVtollTxn
(
  invoicenumber STRING,
  tptripid INT64 NOT NULL,
  citationid INT64 NOT NULL,
  tripstatusid_ct INT64 NOT NULL,
  paymentstatusid INT64,
  firstpaymentdate DATETIME,
  lastpaymentdate DATETIME,
  tolls NUMERIC(31, 2),
  pbmtollamount NUMERIC(31, 2),
  avitollamount NUMERIC(31, 2),
  premiumamount NUMERIC(31, 2),
  paidamount_vt BIGNUMERIC(40, 2),
  tollsadjusted BIGNUMERIC(40, 2),
  outstandingamount NUMERIC(31, 2) NOT NULL,
  edw_updatedate DATETIME NOT NULL
)
cluster by tptripid
;
