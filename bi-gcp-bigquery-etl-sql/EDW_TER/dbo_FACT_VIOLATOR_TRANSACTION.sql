CREATE TABLE  IF NOT EXISTS  EDW_TER.Fact_Violator_Transaction
(
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  transaction_id NUMERIC(29),
  viol_or_toll_transaction STRING NOT NULL,
  lane_id NUMERIC(29),
  license_plate_id INT64,
  viol_status STRING NOT NULL,
  trans_type_id NUMERIC(29) NOT NULL,
  source_code STRING NOT NULL,
  transaction_date DATETIME NOT NULL,
  transaction_time_id INT64,
  toll_due NUMERIC(31, 2) NOT NULL,
  toll_paid NUMERIC(31, 2),
  post_date DATE,
  post_time_id INT64,
  zc_invoice_count INT64,
  viol_invoice_count INT64,
  status_date DATE,
  date_excused DATE,
  toll_transaction_credited_flag INT64 NOT NULL,
  insert_date DATETIME NOT NULL
)
;