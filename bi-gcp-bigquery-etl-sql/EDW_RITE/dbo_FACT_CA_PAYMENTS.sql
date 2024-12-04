## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_CA_PAYMENTS.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Ca_Payments
(
  last_invoice_id INT64 NOT NULL,
  viol_invoice_id INT64 NOT NULL,
  violator_id INT64 NOT NULL,
  ca_acct_id INT64 NOT NULL,
  parent_ca_acct_id INT64 NOT NULL,
  ca_company_id INT64 NOT NULL,
  ca_start_date DATE NOT NULL,
  ca_end_date DATE NOT NULL,
  ca_acct_status STRING NOT NULL,
  ca_acct_status_date DATE NOT NULL,
  ca_inv_status STRING NOT NULL,
  file_gen_date DATE NOT NULL,
  parent_company_id INT64 NOT NULL,
  first_sent_date DATE NOT NULL,
  invoice_date DATETIME NOT NULL,
  viol_inv_status STRING NOT NULL,
  vbi_invoice_id INT64 NOT NULL,
  vb_invoice_date DATETIME NOT NULL,
  vbi_status STRING NOT NULL,
  invoice_amount NUMERIC(31, 2) NOT NULL,
  invoice_amt_disc NUMERIC(31, 2) NOT NULL,
  toll_fee NUMERIC(31, 2) NOT NULL,
  toll_amount NUMERIC(31, 2) NOT NULL,
  trans_cnt INT64 NOT NULL,
  date_excused DATE NOT NULL,
  dps_inv_status STRING NOT NULL,
  vidseq INT64 NOT NULL,
  paymentplanid INT64 NOT NULL,
  hv_start_date DATE NOT NULL,
  hv_end_date DATE NOT NULL,
  payment_date DATE NOT NULL,
  ca_payment_date DATE NOT NULL,
  ca_pmt_rank INT64,
  ca_pmt_flag INT64 NOT NULL,
  late_payment_flag INT64,
  pos_id INT64 NOT NULL,
  delivery_code STRING NOT NULL,
  payment_source_code STRING NOT NULL,
  viol_amount NUMERIC(31, 2) NOT NULL,
  vtoll_amount NUMERIC(31, 2),
  paid_amount NUMERIC(31, 2),
  ca_amount NUMERIC(31, 2),
  paid_till_now NUMERIC(31, 2),
  invoice_viol_amount NUMERIC(31, 2) NOT NULL,
  invoice_vtoll_amount NUMERIC(31, 2) NOT NULL,
  excused_amount NUMERIC(31, 2),
  toll_paid NUMERIC(31, 2),
  fee_paid NUMERIC(31, 2)
)
;
