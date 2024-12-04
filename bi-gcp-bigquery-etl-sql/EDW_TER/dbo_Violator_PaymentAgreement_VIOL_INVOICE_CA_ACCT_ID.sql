CREATE TABLE IF NOT EXISTS EDW_TER.Violator_PaymentAgreement_Viol_Invoice_Ca_Acct_Id
(
  viol_invoice_id NUMERIC(29) NOT NULL,
  ca_acct_id NUMERIC(29)
)
cluster by viol_invoice_id
;