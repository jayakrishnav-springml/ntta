## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Stage
(
  invoice_analysis_category_id INT64 NOT NULL,
  date_batch_produced DATE,
  vbi_invoice_id INT64,
  vb_inv_date DATETIME NOT NULL,
  vb_inv_date_excused DATE NOT NULL,
  zi_stage_id INT64 NOT NULL,
  invoice_stage_id INT64,
  violator_id INT64,
  vb_inv_amt NUMERIC(33, 4) NOT NULL,
  vb_invoice_amt_disc NUMERIC(33, 4) NOT NULL,
  vb_inv_late_fees NUMERIC(33, 4) NOT NULL,
  vb_inv_amt_paid BIGNUMERIC(42, 4),
  converted_date DATE,
  viol_inv_date_excused DATE NOT NULL,
  viol_invoice_id INT64,
  vi_inv_amt NUMERIC(33, 4) NOT NULL,
  vi_invoice_amt_disc NUMERIC(33, 4) NOT NULL,
  paid_date DATE NOT NULL,
  pos_id INT64 NOT NULL,
  payment_source_code STRING NOT NULL,
  delivery_code STRING NOT NULL,
  payment_form STRING NOT NULL,
  payment_created_by STRING NOT NULL,
  viol_inv_fees BIGNUMERIC(40, 2),
  viol_inv_admin_fee NUMERIC(33, 4),
  viol_inv_admin_fee2 NUMERIC(33, 4),
  viol_inv_amt_paid BIGNUMERIC(42, 4),
  ca_inv_status STRING NOT NULL,
  ca_company_id INT64 NOT NULL,
  ca_acct_id NUMERIC(29) NOT NULL,
  ca_file_gen_date DATE NOT NULL,
  citation_nbr STRING NOT NULL,
  court_action_mail_date DATETIME NOT NULL,
  dps_inv_status STRING NOT NULL,
  zc_txn_count INT64,
  viol_txn_count INT64,
  zc_tolls_due NUMERIC(33, 4),
  viol_tolls_due BIGNUMERIC(40, 2)
)
;
