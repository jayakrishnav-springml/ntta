## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_GL_Transactions.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_GL_Transactions
(
  gl_txnid INT64 NOT NULL,
  postingdate DATETIME NOT NULL,
  postingdate_yyyymm INT64 NOT NULL,
  customerid INT64 NOT NULL,
  txntypeid INT64 NOT NULL,
  businessprocessid INT64 NOT NULL,
  linkid INT64 NOT NULL,
  linksourcename STRING,
  txndate DATETIME NOT NULL,
  txnamount NUMERIC(31, 2) NOT NULL,
  iscontra INT64,
  description STRING,
  requestid INT64,
  businessunitid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  deleteflag INT64,
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)
cluster by gl_txnid
;