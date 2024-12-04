## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_VIOL_INVOICES.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Viol_Invoices
(
  viol_invoice_id INT64,
  invoice_date STRING,
  invoice_amount NUMERIC(33, 4) NOT NULL,
  invoice_amt_paid NUMERIC(33, 4),
  invoice_amt_disc NUMERIC(33, 4) NOT NULL,
  viol_inv_batch_id NUMERIC(29) NOT NULL,
  viol_inv_status STRING NOT NULL,
  violator_addr_seq INT64 NOT NULL,
  violator_id INT64,
  inv_admin_fee NUMERIC(33, 4),
  inv_admin_fee2 NUMERIC(33, 4),
  ca_inv_status STRING NOT NULL,
  dps_inv_status STRING NOT NULL,
  date_excused DATE,
  excused_by STRING,
  curr_due_date DATETIME,
  invoice_days_to_excused INT64,
  status_date DATETIME NOT NULL,
  date_modified DATETIME NOT NULL,
  close_out_eligibility_date DATE NOT NULL,
  close_out_status STRING NOT NULL,
  close_out_date DATE NOT NULL,
  close_out_type STRING NOT NULL,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by VIOLATOR_ID,VIOL_INVOICE_ID
;
