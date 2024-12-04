## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_GL_IOP_UnidentifiedAgingTxnSnapshot.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot
(
  snapshotdate DATE,
  snapshotmonthid INT64 NOT NULL,
  gl_txnid INT64 NOT NULL,
  tptripid INT64 NOT NULL,
  laneid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  businessunitid INT64,
  postingdate DATE,
  txndate DATE,
  txnamount NUMERIC(31, 2) NOT NULL,
  daycountid INT64
)
;