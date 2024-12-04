## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_GL_Txn_LineItems.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_GL_Txn_LineItems
(
  pk_id INT64 NOT NULL,
  gl_txnid INT64 NOT NULL,
  description STRING,
  chartofaccountid INT64 NOT NULL,
  debitamount NUMERIC(31, 2) NOT NULL,
  creditamount NUMERIC(31, 2) NOT NULL,
  specialjournalid INT64,
  drcr_flag STRING,
  txntype_li_id INT64,
  txntypeid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  deleteflag INT64,
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)
cluster by pk_id
;