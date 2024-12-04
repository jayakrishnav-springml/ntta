## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_PAYMENT_LINE_ITEMS_VPS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Payment_Line_Items_Vps
(
  payment_line_item_id INT64,
  payment_txn_id INT64,
  pmt_txn_type STRING,
  payment_form STRING,
  credit_card_type STRING,
  payment_line_item_amount NUMERIC(31, 2),
  payment_status STRING,
  ref_line_item_id INT64,
  last_update_date DATETIME
)
cluster by payment_line_item_id
;
