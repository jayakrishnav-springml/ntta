## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VIOLATION_VB_VIOL_XREF_OLD.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Violation_Vb_Viol_Xref_Old
(
  partition_values INT64 NOT NULL,
  last_invoice_id INT64 NOT NULL,
  violation_id INT64,
  viol_status STRING,
  vbi_invoice_id INT64 NOT NULL,
  viol_invoice_id INT64 NOT NULL,
  vb_invoice_date DATE,
  viol_invoice_date DATETIME,
  toll_due NUMERIC(31, 2),
  fine_amount NUMERIC(31, 2) NOT NULL,
  delete_status INT64,
  current_flag INT64
)
cluster by violation_id
;
