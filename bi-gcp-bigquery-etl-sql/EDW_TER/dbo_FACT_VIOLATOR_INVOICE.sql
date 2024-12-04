CREATE TABLE IF NOT EXISTS EDW_TER.Fact_Violator_Invoice
(
  violatorid INT64,
  vidseq INT64 NOT NULL,
  invoice_type STRING NOT NULL,
  zi_stage_id INT64 NOT NULL,
  invoice_id INT64 NOT NULL,
  invoice_date DATETIME,
  invoice_due_date DATETIME,
  date_excused DATETIME,
  invoice_amount NUMERIC(31, 2),
  late_fee_amount NUMERIC(31, 2),
  past_due_amount NUMERIC(31, 2),
  inv_admin_fee NUMERIC(31, 2),
  inv_admin_fee2 NUMERIC(31, 2),
  invoice_amt_paid NUMERIC(31, 2),
  invoice_batch_id NUMERIC(29),
  ca_inv_status STRING,
  dps_inv_status STRING,
  toll_paid BIGNUMERIC(40, 2),
  invoice_status STRING,
  toll_due_amount NUMERIC(31, 2),
  fine_amount NUMERIC(31, 2),
  date_modified DATETIME,
  insert_date DATETIME NOT NULL
)
cluster by invoice_id
;
