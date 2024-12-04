## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_PAYMENT_XREF_VPS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Payment_Xref_Vps
(
  payment_xref_id INT64,
  payment_line_item_id INT64 NOT NULL,
  violation_id INT64,
  viol_invoice_id FLOAT64,
  vbi_vbi_invoice_id NUMERIC(29),
  payment_status STRING NOT NULL,
  transaction_type STRING NOT NULL,
  split_amount NUMERIC(33, 4) NOT NULL,
  insert_datetime DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by payment_xref_id
;
