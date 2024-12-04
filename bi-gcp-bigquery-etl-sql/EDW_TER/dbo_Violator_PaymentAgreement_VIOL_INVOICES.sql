CREATE TABLE IF NOT EXISTS EDW_TER.Violator_PaymentAgreement_Viol_Invoices
(
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  instancenbr INT64,
  altviolatorid INT64,
  viol_invoice_id INT64,
  invoice_date STRING,
  invoice_amount NUMERIC(33, 4) NOT NULL,
  invoice_amt_paid NUMERIC(33, 4),
  viol_inv_batch_id NUMERIC(29) NOT NULL,
  viol_inv_status STRING NOT NULL,
  toll_due_amount BIGNUMERIC(40, 2),
  fine_amount BIGNUMERIC(40, 2),
  paid_amount BIGNUMERIC(40, 2),
  viol_inv_status_descr STRING NOT NULL,
  invoice_status_date DATETIME NOT NULL
)
cluster by violatorid
;