## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_UNIFIED_VIOLATION_PAYMENT.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Unified_Violation_Payment
(
  violation_id FLOAT64,
  violator_id NUMERIC(29),
  vbi_invoice_id NUMERIC(29),
  viol_invoice_id NUMERIC(29),
  toll_due NUMERIC(33, 4),
  payment_date DATETIME,
  split_amount NUMERIC(33, 4),
  fees_paid NUMERIC(33, 4),
  toll_paid NUMERIC(33, 4)
)
;
