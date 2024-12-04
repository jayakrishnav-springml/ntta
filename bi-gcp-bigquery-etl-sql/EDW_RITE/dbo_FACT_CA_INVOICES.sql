## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_CA_INVOICES.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Ca_Invoices
(
  last_invoice_id INT64 NOT NULL,
  violator_id INT64,
  ca_acct_id INT64,
  parent_ca_acct_id INT64 NOT NULL,
  file_gen_date DATE,
  first_sent_date DATE,
  ca_company_id INT64,
  parent_company_id INT64,
  ca_start_date DATE NOT NULL,
  ca_end_date DATE NOT NULL,
  ca_acct_status STRING NOT NULL,
  ca_acct_status_date DATE,
  ca_inv_status STRING NOT NULL,
  dps_inv_status STRING,
  viol_invoice_id INT64,
  viol_invoice_date DATETIME,
  viol_inv_status STRING,
  viol_inv_status_date DATE,
  vbi_invoice_id INT64 NOT NULL,
  vb_invoice_date DATETIME,
  vbi_status STRING,
  date_excused DATE,
  excused_by STRING,
  invoice_amount NUMERIC(31, 2),
  invoice_amt_disc NUMERIC(31, 2),
  toll_fee NUMERIC(31, 2),
  toll_amount NUMERIC(31, 2),
  trans_cnt INT64,
  lv_trans_cnt INT64,
  lv_toll_due NUMERIC(31, 2)
)
;
