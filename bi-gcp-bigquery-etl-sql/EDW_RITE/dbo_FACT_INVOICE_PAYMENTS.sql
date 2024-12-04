## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_PAYMENTS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Payments
(
  last_invoice_id INT64,
  payment_id INT64,
  vbi_invoice_id INT64 NOT NULL,
  viol_invoice_id INT64 NOT NULL,
  violator_id NUMERIC(29) NOT NULL,
  payment_date DATE,
  deposit_date DATE,
  shift_id INT64 NOT NULL,
  pos_id INT64 NOT NULL,
  delivery_code STRING NOT NULL,
  payment_source_code STRING NOT NULL,
  payment_form STRING,
  toll_due NUMERIC(31, 2),
  fees_due NUMERIC(31, 2),
  viol_amount NUMERIC(31, 2),
  vtoll_amount NUMERIC(31, 2),
  paid_amount NUMERIC(31, 2),
  invoice_viol_amount NUMERIC(31, 2),
  invoice_vtoll_amount NUMERIC(31, 2),
  invoice_paid_amount NUMERIC(31, 2)
)
cluster by PAYMENT_ID,VBI_INVOICE_ID,VIOL_INVOICE_ID
;
