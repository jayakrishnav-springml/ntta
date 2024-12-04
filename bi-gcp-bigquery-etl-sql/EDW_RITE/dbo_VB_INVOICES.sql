## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VB_INVOICES.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Vb_Invoices
(
  vbi_invoice_id INT64,
  vbi_status STRING NOT NULL,
  vbb_batch_id NUMERIC(29) NOT NULL,
  violator_id INT64 NOT NULL,
  violator_addr_seq INT64 NOT NULL,
  invoice_date DATETIME NOT NULL,
  invoice_amount NUMERIC(33, 4) NOT NULL,
  invoice_amt_disc NUMERIC(33, 4) NOT NULL,
  late_fee_amount NUMERIC(33, 4) NOT NULL,
  past_due_amount NUMERIC(33, 4) NOT NULL,
  invoice_amt_paid NUMERIC(33, 4),
  toll_amount NUMERIC(33, 4) NOT NULL,
  vbb_ln_batch_id NUMERIC(29),
  date_excused DATE,
  excused_by STRING,
  invoice_days_to_excused INT64,
  due_date DATETIME NOT NULL,
  date_modified DATETIME NOT NULL,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by vbi_invoice_id,violator_id
;
