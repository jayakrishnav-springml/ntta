## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_ANALYSIS_DETAIL_AMT_PAID_ADJ_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Analysis_Detail_Amt_Paid_Adj_Stage
(
  violator_id NUMERIC(29) NOT NULL,
  vbi_invoice_id INT64 NOT NULL,
  viol_invoice_id INT64,
  violation_id NUMERIC(29) NOT NULL,
  amt_paid_disc BIGNUMERIC(45, 7),
  amt_paid_adj BIGNUMERIC(45, 7)
)
;
