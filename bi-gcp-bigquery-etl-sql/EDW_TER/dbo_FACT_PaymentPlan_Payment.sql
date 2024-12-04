CREATE TABLE IF NOT EXISTS EDW_TER.Fact_PaymentPlan_Payment
(
  paymentplanid INT64 NOT NULL,
  violatorid INT64,
  vidseq INT64 NOT NULL,
  vbi_invoice_id INT64 NOT NULL,
  viol_invoice_id INT64,
  payment_date DATETIME,
  split_amount NUMERIC(33, 4)
)
;
