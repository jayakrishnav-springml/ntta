CREATE TABLE IF NOT EXISTS EDW_TER.Fact_PaymentPlan_Invoice
(
  paymentplanid INT64 NOT NULL,
  violatorid INT64,
  vidseq INT64 NOT NULL,
  vbi_invoice_id INT64 NOT NULL,
  viol_invoice_id INT64,
  tolls_due BIGNUMERIC(40, 2),
  fees_due BIGNUMERIC(40, 2),
  invoice_amount NUMERIC(33, 4)
)
;