## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_VB_VIOL_INVOICES_NEW_SET.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Vb_Viol_Invoices_New_Set
(
  violator_id INT64 NOT NULL,
  violator_addr_seq INT64 NOT NULL,
  toll_amount BIGNUMERIC(40, 2),
  vbi_invoice_id INT64 NOT NULL,
  vbi_status STRING NOT NULL,
  vb_invoice_date DATETIME NOT NULL,
  vb_invoice_amt NUMERIC(33, 4) NOT NULL,
  vb_invoice_amt_disc NUMERIC(33, 4) NOT NULL,
  vb_late_fee_amount NUMERIC(33, 4) NOT NULL,
  vb_past_due_amount NUMERIC(33, 4) NOT NULL,
  vb_invoice_amt_paid NUMERIC(33, 4) NOT NULL,
  vb_past_due_late_fee_amount NUMERIC(33, 4) NOT NULL,
  vb_past_due_mail_fee_amount NUMERIC(33, 4) NOT NULL,
  vbb_ln_batch_id NUMERIC(29) NOT NULL,
  vb_date_excused DATETIME NOT NULL,
  vb_excused_by STRING NOT NULL,
  vb_invoice_days_to_excused INT64,
  vb_due_date DATETIME NOT NULL,
  viol_invoice_id NUMERIC(29) NOT NULL,
  viol_inv_status STRING NOT NULL,
  viol_invoice_date STRING NOT NULL,
  viol_invoice_amt NUMERIC(33, 4) NOT NULL,
  viol_invoice_amt_paid NUMERIC(33, 4) NOT NULL,
  viol_invoice_amt_disc NUMERIC(33, 4) NOT NULL,
  viol_inv_admin_fee NUMERIC(33, 4) NOT NULL,
  viol_inv_admin_fee2 NUMERIC(33, 4) NOT NULL,
  viol_fine_amount BIGNUMERIC(40, 2) NOT NULL,
  ca_inv_status STRING NOT NULL,
  dps_inv_status STRING NOT NULL,
  viol_inv_date_excused DATETIME NOT NULL,
  viol_inv_excused_by STRING NOT NULL,
  viol_inv_curr_due_date DATETIME NOT NULL,
  viol_invoice_days_to_excused INT64,
  viol_inv_status_date DATETIME NOT NULL,
  viol_inv_date_modified DATETIME NOT NULL,
  close_out_eligibility_date DATE NOT NULL,
  close_out_status STRING NOT NULL,
  close_out_date DATE NOT NULL,
  close_out_type STRING NOT NULL
)
;
