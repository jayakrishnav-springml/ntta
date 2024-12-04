CREATE TABLE IF NOT EXISTS EDW_TER.Violator_Invoice_Payment_Pos_Hist
(
  generation_date DATE,
  paymentplanid INT64 NOT NULL,
  planstartdate DATETIME NOT NULL,
  firstpaymentdate DATETIME NOT NULL,
  lastpaymentdate DATETIME NOT NULL,
  violator_id INT64 NOT NULL,
  vbi_invoice_id INT64 NOT NULL,
  viol_invoice_id NUMERIC(29) NOT NULL,
  payment_date DATETIME NOT NULL,
  pos_name STRING,
  payment_source_code_descr STRING,
  delivery_descr STRING,
  payment_form_descr STRING,
  user_name STRING,
  pmt_created_by STRING NOT NULL
)
;