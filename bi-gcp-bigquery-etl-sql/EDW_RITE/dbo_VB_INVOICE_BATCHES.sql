## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VB_INVOICE_BATCHES.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Vb_Invoice_Batches
(
  vbb_batch_id NUMERIC(29) NOT NULL,
  date_produced DATETIME NOT NULL,
  vb_inv_batch_type_code STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
