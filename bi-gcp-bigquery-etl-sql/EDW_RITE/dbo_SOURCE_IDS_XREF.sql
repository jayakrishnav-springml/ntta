## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_SOURCE_IDS_XREF.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Source_Ids_Xref
(
  tart_id NUMERIC(29) NOT NULL,
  violation_id NUMERIC(29),
  lane_viol_id NUMERIC(29),
  transaction_id NUMERIC(29),
  transaction_file_detail_id NUMERIC(29),
  source_txn_id INT64,
  ttxn_id INT64
)
cluster by tart_id
;
