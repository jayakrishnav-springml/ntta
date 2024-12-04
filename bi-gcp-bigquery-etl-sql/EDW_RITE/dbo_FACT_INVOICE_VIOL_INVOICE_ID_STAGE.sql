## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_VIOL_INVOICE_ID_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Viol_Invoice_Id_Stage
(
  viol_invoice_id FLOAT64,
  date_paid DATE,
  pos_id INT64,
  payment_source_code STRING NOT NULL,
  payment_form STRING,
  delivery_code STRING NOT NULL,
  payment_created_by STRING
)
;
