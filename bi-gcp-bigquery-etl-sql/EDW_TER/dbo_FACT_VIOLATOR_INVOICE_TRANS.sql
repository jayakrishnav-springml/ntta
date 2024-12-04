CREATE TABLE IF NOT EXISTS  EDW_TER.Fact_Violator_Invoice_Trans
(
  violatorid INT64,
  vidseq INT64 NOT NULL,
  invoice_type STRING NOT NULL,
  invoice_id INT64,
  trans_id INT64 NOT NULL,
  viol_status STRING,
  toll_due_amount NUMERIC(33, 4),
  fine_amount NUMERIC(31, 2),
  toll_paid NUMERIC(31, 2) NOT NULL,
  viol_date DATETIME NOT NULL,
  viol_time_id INT64,
  post_date DATE,
  post_time_id INT64,
  insert_date DATETIME NOT NULL
)
;