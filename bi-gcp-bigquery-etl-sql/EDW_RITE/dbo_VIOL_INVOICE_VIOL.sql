## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VIOL_INVOICE_VIOL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Viol_Invoice_Viol
(
  violation_id INT64 NOT NULL,
  viol_invoice_id INT64 NOT NULL,
  viol_status STRING,
  toll_due_amount NUMERIC(31, 2),
  fine_amount NUMERIC(31, 2),
  last_update_type STRING,
  last_update_date DATETIME
)
cluster by viol_invoice_id

;
