## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VB_INVOICE_VIOL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Vb_Invoice_Viol
(
  vbi_invoice_id INT64 NOT NULL,
  violation_id INT64 NOT NULL,
  toll_due NUMERIC(33, 4) NOT NULL,
  viol_status STRING,
  date_created DATE,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by vbi_invoice_id,violation_id
;
