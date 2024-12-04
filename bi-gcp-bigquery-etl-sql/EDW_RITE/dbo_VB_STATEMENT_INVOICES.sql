## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VB_STATEMENT_INVOICES.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Vb_Statement_Invoices
(
  vbsi_statement_id NUMERIC(29) NOT NULL,
  violator_id NUMERIC(29) NOT NULL,
  vbi_invoice_id NUMERIC(29) NOT NULL,
  viol_invoice_id NUMERIC(29) NOT NULL,
  last_update_type STRING,
  last_update_date DATETIME
)
cluster by vbsi_statement_id
;
