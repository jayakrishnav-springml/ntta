## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_VB_INVOICE_SUM_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Vb_Invoice_Sum_Stage
(
  violator_id INT64 NOT NULL,
  vbi_invoice_id INT64,
  zc_tolls_due NUMERIC(33, 4),
  zc_txn_count INT64
)
cluster by vbi_invoice_id
;
