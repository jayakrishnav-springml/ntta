## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VB_VIOL_INVOICES.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Vb_Viol_Invoices
(
  violator_id NUMERIC(29),
  vbi_vbi_invoice_id NUMERIC(29) NOT NULL,
  inv_viol_invoice_id NUMERIC(29) NOT NULL,
  date_created DATETIME,
  last_update_type STRING,
  last_update_date DATETIME
)
cluster by vbi_vbi_invoice_id,inv_viol_invoice_id
;
