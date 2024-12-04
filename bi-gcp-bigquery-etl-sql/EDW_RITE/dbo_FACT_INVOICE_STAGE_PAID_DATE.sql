## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_STAGE_PAID_DATE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Stage_Paid_Date
(
  violator_id INT64 NOT NULL,
  vbi_invoice_id INT64 NOT NULL,
  viol_invoice_id INT64,
  first_paid_date DATE,
  paid_date DATE,
  paid_date_list STRING,
  paid_date_count INT64
)
;
