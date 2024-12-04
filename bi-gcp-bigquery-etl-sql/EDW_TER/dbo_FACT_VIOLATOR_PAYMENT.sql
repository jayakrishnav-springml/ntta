CREATE TABLE IF NOT EXISTS  EDW_TER.Fact_Violator_Payment
(
  violatorid INT64,
  vidseq INT64 NOT NULL,
  payment_txn_id INT64 NOT NULL,
  licenseplateid INT64 NOT NULL,
  card_code STRING NOT NULL,
  payment_source_code STRING NOT NULL,
  viol_pay_type STRING NOT NULL,
  payment_status STRING NOT NULL,
  pmt_txn_type STRING,
  retail_trans_id INT64,
  trans_date DATE,
  trans_amt NUMERIC(33, 4),
  created_by STRING NOT NULL,
  pos_name STRING,
  inv_toll_amt BIGNUMERIC(40, 2),
  inv_fees_amt BIGNUMERIC(40, 2),
  invoice_type STRING,
  amount_due NUMERIC(33, 4),
  viol_invoice_id FLOAT64,
  vbi_vbi_invoice_id NUMERIC(29),
  insert_date DATETIME NOT NULL
)
cluster by payment_txn_id
;
