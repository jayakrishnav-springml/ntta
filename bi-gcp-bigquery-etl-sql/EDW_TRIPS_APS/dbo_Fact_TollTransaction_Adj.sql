## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_TollTransaction_Adj.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_TollTransaction_Adj
(
  custtripid INT64 NOT NULL,
  adjlineitemid INT64 NOT NULL,
  adjustmentid INT64 NOT NULL,
  tptripid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  laneid INT64 NOT NULL,
  tripidentmethodid INT64 NOT NULL,
  tripdayid INT64 NOT NULL,
  adjusteddayid INT64 NOT NULL,
  tripdate DATETIME NOT NULL,
  posteddate DATETIME NOT NULL,
  adjusteddate DATETIME NOT NULL,
  drcrflag STRING,
  deleteflag INT64 NOT NULL,
  adjustedtollamount NUMERIC(31, 2) NOT NULL,
  lnd_updatedate DATETIME NOT NULL,
  edw_updatedate DATETIME NOT NULL
)
cluster by custtripid
;