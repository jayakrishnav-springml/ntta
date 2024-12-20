## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_FACT_INVOICE_ANALYSIS_SECOND_STAGE.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Fact_Invoice_Analysis_Second_Stage
(
  violator_id INT64 NOT NULL,
  partition_date DATE NOT NULL,
  date_batch_produced STRING NOT NULL,
  vbi_invoice_id INT64 NOT NULL,
  vb_inv_date STRING NOT NULL,
  vb_inv_due_date STRING NOT NULL,
  vb_inv_date_excused STRING NOT NULL,
  vb_inv_excused_by INT64,
  vb_inv_date_modified STRING NOT NULL,
  zi_stage_id INT64 NOT NULL,
  invoice_stage_id INT64 NOT NULL,
  vbi_status STRING NOT NULL,
  converted_date STRING NOT NULL,
  viol_inv_status_date STRING NOT NULL,
  viol_inv_due_date STRING NOT NULL,
  viol_inv_date_excused STRING NOT NULL,
  viol_inv_excused_by INT64,
  viol_inv_date_modified STRING NOT NULL,
  viol_invoice_id INT64 NOT NULL,
  viol_inv_status STRING NOT NULL,
  `3nnp_inv_date` STRING NOT NULL,
  first_paid_date DATE NOT NULL,
  last_paid_date DATE NOT NULL,
  paid_date_list STRING,
  paid_date_count INT64 NOT NULL,
  first_pos_id INT64 NOT NULL,
  last_pos_id INT64 NOT NULL,
  pos_name_list INT64,
  pos_count INT64 NOT NULL,
  payment_source_code STRING NOT NULL,
  delivery_code STRING NOT NULL,
  payment_form STRING NOT NULL,
  payment_created_by INT64,
  ca_inv_status STRING NOT NULL,
  first_ca_company_id INT64 NOT NULL,
  last_ca_company_id INT64 NOT NULL,
  ca_company_name_list INT64,
  ca_company_count INT64 NOT NULL,
  first_ca_file_gen_date STRING NOT NULL,
  last_ca_file_gen_date STRING NOT NULL,
  ca_file_gen_date_list INT64,
  ca_file_gen_date_count INT64 NOT NULL,
  first_citation_nbr INT64,
  last_citation_nbr INT64,
  citation_nbr_list INT64,
  citation_nbr_count INT64 NOT NULL,
  first_ca_acct_id INT64 NOT NULL,
  last_ca_acct_id INT64 NOT NULL,
  ca_acct_id_list INT64,
  ca_acct_id_count INT64 NOT NULL,
  court_action_mail_date STRING NOT NULL,
  dps_inv_status STRING NOT NULL,
  invoice_amt INT64 NOT NULL,
  invoice_amt_disc INT64 NOT NULL,
  invoice_tolls_paid_calc INT64 NOT NULL,
  toll_due NUMERIC(33, 4) NOT NULL,
  zi_late_fees INT64 NOT NULL,
  vi_late_fees INT64 NOT NULL,
  admin_fee INT64 NOT NULL,
  admin_fee2 INT64 NOT NULL,
  amt_paid NUMERIC(31, 2) NOT NULL,
  viol_count INT64 NOT NULL,
  close_out_eligibility_date STRING NOT NULL,
  close_out_status STRING NOT NULL,
  close_out_date STRING NOT NULL,
  close_out_type STRING NOT NULL,
  current_invoice_flag INT64 NOT NULL,
  toll_due_left_on_inv INT64 NOT NULL,
  txn_cnt_left_on_inv INT64 NOT NULL,
  insert_date DATETIME NOT NULL
)
;
