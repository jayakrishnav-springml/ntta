## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_ANALYSIS_AMT_PAID_ADJ_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Analysis_Amt_Paid_Adj_Stage
(
  violator_id INT64,
  vbi_invoice_id INT64,
  viol_invoice_id INT64 NOT NULL,
  invoice_tolls_paid_calc NUMERIC(37, 8),
  sum_amt_paid_from_dtl NUMERIC(37, 8),
  disc_amount NUMERIC(37, 8),
  toll_due_per_viol_left_on_inv BIGNUMERIC(45, 7)
)
;
