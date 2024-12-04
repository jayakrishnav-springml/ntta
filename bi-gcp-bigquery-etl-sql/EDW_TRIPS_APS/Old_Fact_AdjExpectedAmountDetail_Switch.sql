## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Old_Fact_AdjExpectedAmountDetail_Switch.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_AdjExpectedAmountDetail_Switch
(
  tptripid INT64 NOT NULL,
  custtripid INT64,
  citationid INT64,
  currenttxnflag INT64,
  tripdayid INT64,
  sourceid INT64,
  sourcename STRING,
  tolladjustmentid INT64,
  adjustmentreason STRING,
  txnseqasc INT64,
  txndate DATETIME,
  amount BIGNUMERIC(40, 2),
  runningtotalamount BIGNUMERIC(40, 2),
  runningalladjamount BIGNUMERIC(40, 2),
  runningtripwithadjamount BIGNUMERIC(40, 2),
  txnseqdesc INT64,
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)
;