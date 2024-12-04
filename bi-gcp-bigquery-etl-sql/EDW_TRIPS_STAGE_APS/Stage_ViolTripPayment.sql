## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_ViolTripPayment.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.ViolTripPayment
(
  tptripid INT64 NOT NULL,
  citationid INT64 NOT NULL,
  tripstatusid INT64 NOT NULL,
  totaltxnamount NUMERIC(31, 2),
  tollamount NUMERIC(31, 2) NOT NULL,
  adjustedamount NUMERIC(31, 2),
  actualpaidamount NUMERIC(31, 2),
  outstandingamount NUMERIC(31, 2) NOT NULL,
  paymentstatusid INT64,
  firstpaiddate DATETIME,
  lastpaiddate DATETIME
)
;