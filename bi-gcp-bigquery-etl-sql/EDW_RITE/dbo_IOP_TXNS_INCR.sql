## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_IOP_TXNS_INCR.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Iop_Txns_Incr
(
  source_txn_id INT64,
  earned_revenue NUMERIC(31, 2),
  posted_revenue NUMERIC(31, 2),
  source_code STRING NOT NULL
)
;
