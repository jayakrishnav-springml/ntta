## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_VB_VIOL_INVOICES.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Vb_Viol_Invoices
(
  last_invoice_id INT64 NOT NULL,
  vbi_invoice_id INT64 NOT NULL,
  viol_invoice_id INT64 NOT NULL,
  violator_id INT64 NOT NULL,
  violator_addr_seq INT64 NOT NULL,
  toll_amount NUMERIC(31, 2) NOT NULL,
  fees_amount NUMERIC(31, 2) NOT NULL,
  legacy_toll_amount NUMERIC(31, 2) NOT NULL,
  legacy_fees_amount NUMERIC(31, 2) NOT NULL,
  paid_amount NUMERIC(31, 2) NOT NULL,
  toll_paid NUMERIC(31, 2) NOT NULL,
  fees_paid NUMERIC(31, 2) NOT NULL,
  paid_date DATE NOT NULL,
  vb_invoice_days_to_paid INT64 NOT NULL,
  vbi_status STRING NOT NULL,
  vb_invoice_date DATETIME NOT NULL,
  vb_invoice_amt NUMERIC(31, 2) NOT NULL,
  vb_invoice_amt_disc NUMERIC(31, 2) NOT NULL,
  vb_late_fee_amount NUMERIC(31, 2) NOT NULL,
  vb_past_due_amount NUMERIC(31, 2) NOT NULL,
  vb_invoice_amt_paid NUMERIC(31, 2) NOT NULL,
  vbb_ln_batch_id INT64 NOT NULL,
  vb_date_excused DATETIME NOT NULL,
  vb_excused_by STRING NOT NULL,
  vb_invoice_days_to_excused INT64 NOT NULL,
  vb_due_date DATETIME NOT NULL,
  vb_mail_date DATETIME NOT NULL,
  viol_inv_status STRING NOT NULL,
  viol_invoice_date DATETIME NOT NULL,
  viol_invoice_amt NUMERIC(31, 2) NOT NULL,
  viol_invoice_amt_paid NUMERIC(31, 2) NOT NULL,
  viol_invoice_amt_disc NUMERIC(31, 2) NOT NULL,
  viol_inv_admin_fee NUMERIC(31, 2) NOT NULL,
  viol_inv_admin_fee2 NUMERIC(31, 2) NOT NULL,
  viol_fine_amount NUMERIC(31, 2) NOT NULL,
  viol_inv_date_excused DATETIME NOT NULL,
  viol_inv_excused_by STRING NOT NULL,
  viol_inv_curr_due_date DATETIME NOT NULL,
  viol_invoice_days_to_excused INT64 NOT NULL,
  viol_inv_status_date DATETIME NOT NULL,
  viol_inv_date_modified DATETIME NOT NULL,
  ca_inv_status STRING NOT NULL,
  dps_inv_status STRING NOT NULL,
  close_out_eligibility_date DATETIME NOT NULL,
  close_out_status STRING NOT NULL,
  close_out_date DATETIME NOT NULL,
  close_out_type STRING NOT NULL,
  hv_flag INT64 NOT NULL,
  pp_flag INT64 NOT NULL
)
CLUSTER BY vbi_invoice_id,viol_invoice_id;
