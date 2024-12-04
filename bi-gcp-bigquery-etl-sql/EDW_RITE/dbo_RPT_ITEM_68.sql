## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_RPT_ITEM_68.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Rpt_Item_68
(
  pmt_date DATETIME,
  user_name STRING,
  txn_type STRING,
  receipt_id STRING,
  vtolled_inv_count INT64,
  vtolled_viol_count INT64,
  total_vtolled_amount NUMERIC(32, 3),
  tot_pmt_count NUMERIC(32, 3),
  tot_pmt_amt_collected NUMERIC(32, 3),
  num_accts_opened INT64
)
;
