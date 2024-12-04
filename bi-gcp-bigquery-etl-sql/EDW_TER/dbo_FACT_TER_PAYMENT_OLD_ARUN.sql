CREATE TABLE IF NOT EXISTS EDW_TER.Fact_Ter_Payment_Old_Arun
(
  paymentplanid INT64 NOT NULL,
  violator_id INT64,
  vidseq INT64,
  vbi_invoice_id NUMERIC(29) NOT NULL,
  viol_invoice_id NUMERIC(29) NOT NULL,
  payment_date DATETIME,
  payment_mth STRING,
  split_amount BIGNUMERIC(40, 2)
)
;