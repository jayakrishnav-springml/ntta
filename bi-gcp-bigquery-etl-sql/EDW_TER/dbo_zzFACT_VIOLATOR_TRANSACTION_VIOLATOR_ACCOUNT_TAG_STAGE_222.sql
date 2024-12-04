CREATE TABLE IF NOT EXISTS EDW_TER.zzFact_Violator_Transaction_Violator_Account_Tag_Stage_222
(
  violator_id INT64 NOT NULL,
  vid_seq INT64 NOT NULL,
  transaction_id INT64 NOT NULL,
  transaction_type STRING NOT NULL,
  lane_id INT64 NOT NULL,
  license_plate_id INT64 NOT NULL,
  viol_status STRING NOT NULL,
  trans_type_id INT64 NOT NULL,
  source_code STRING NOT NULL,
  transaction_date STRING,
  transaction_time_id INT64,
  toll_due NUMERIC(33, 4) NOT NULL,
  toll_paid NUMERIC(33, 4),
  post_date STRING,
  post_time_id INT64,
  zc_invoice_count INT64,
  viol_invoice_count INT64,
  status_date STRING NOT NULL,
  date_excused STRING NOT NULL,
  toll_transaction_credited_flag INT64 NOT NULL,
  insert_date DATETIME NOT NULL
)
;