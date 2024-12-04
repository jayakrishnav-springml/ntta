## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VIOLATION_LAST_VIOL_INVOICE_MAX_INVOICE_ID_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Violation_Last_Viol_Invoice_Max_Invoice_Id_Stage
(
  violator_id INT64 NOT NULL,
  violation_id INT64 NOT NULL,
  last_viol_invoice_date DATE,
  viol_invoice_id INT64
)
cluster by violator_id,violation_id
;
