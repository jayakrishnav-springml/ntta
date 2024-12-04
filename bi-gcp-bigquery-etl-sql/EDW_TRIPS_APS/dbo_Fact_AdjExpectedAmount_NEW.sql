## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_AdjExpectedAmount_NEW.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_AdjExpectedAmount_NEW
(
  tptripid INT64 NOT NULL,
  tripdayid INT64,
  classadjustmentflag INT64,
  adjustedexpectedamount NUMERIC(31, 2),
  tripwithadjustedamount NUMERIC(31, 2),
  alladjustedamount NUMERIC(31, 2),
  allcusttripadjustedamount NUMERIC(31, 2),
  allviolatedtripadjustedamount NUMERIC(31, 2),
  iop_outboundpaidamount NUMERIC(31, 2),
  edw_updatedate DATETIME
)
cluster by tptripid
;