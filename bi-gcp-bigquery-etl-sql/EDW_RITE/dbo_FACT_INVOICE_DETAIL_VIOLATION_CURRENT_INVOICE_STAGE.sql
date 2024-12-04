## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_DETAIL_VIOLATION_CURRENT_INVOICE_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Detail_Violation_Current_Invoice_Stage
(
  violation_id INT64 NOT NULL,
  vbi_invoice_id INT64,
  viol_invoice_id INT64
)
;
