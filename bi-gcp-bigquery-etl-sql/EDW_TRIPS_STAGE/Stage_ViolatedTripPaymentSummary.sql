## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_ViolatedTripPaymentSummary.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.ViolatedTripPaymentSummary
(
  tptripid INT64 NOT NULL,
  citationid INT64,
  tripwith STRING,
  firstpaiddate DATETIME,
  lastpaiddate DATETIME,
  paidamount NUMERIC(31, 2),
  adjamount NUMERIC(31, 2),
  paymenttxncount INT64,
  adjtxncount INT64
)
;