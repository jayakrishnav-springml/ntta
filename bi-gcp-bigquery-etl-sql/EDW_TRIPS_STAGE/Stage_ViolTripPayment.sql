-- Translation time: 2024-07-11T07:10:16.441155Z
-- Translation job ID: 01f97d19-b914-463a-8c9e-73c23536d6e1
-- Source: gs://ntta-gcp-poc-source-code-scripts/transpiled_ddl_tmp/ITEM_90_NEW_APS/Stage.ViolTripPayment.dsql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.ViolTripPayment
(
  tptripid INT64 NOT NULL,
  citationid INT64 NOT NULL,
  vtollflag INT64 NOT NULL,
  tripstatusid INT64,
  totaltxnamount NUMERIC(31, 2),
  tollamount NUMERIC(31, 2) NOT NULL,
  adjustedamount BIGNUMERIC(40, 2),
  actualpaidamount BIGNUMERIC(40, 2),
  outstandingamount NUMERIC(31, 2),
  paymentstatusid INT64,
  firstpaiddate DATETIME,
  lastpaiddate DATETIME,
  excuseddate DATETIME,
  edw_updatedate DATETIME
)
;
