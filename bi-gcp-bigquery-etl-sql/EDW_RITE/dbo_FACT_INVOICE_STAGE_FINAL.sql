## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_STAGE_FINAL.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Stage_Final
(
  violator_id INT64,
  vbi_invoice_id INT64,
  viol_invoice_id INT64,
  ca_file_gen_date DATE NOT NULL,
  ca_acct_id NUMERIC(29) NOT NULL,
  citation_nbr STRING NOT NULL,
  paid_date DATE NOT NULL,
  pos_id INT64 NOT NULL,
  delivery_code STRING NOT NULL,
  payment_source_code STRING NOT NULL,
  invoice_break_rownum INT64,
  current_invoice_level_flag INT64 NOT NULL
)
;
