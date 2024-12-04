
CREATE TABLE IF NOT EXISTS EDW_TER.Violator_PaymentAgreement_Viol_Invoices_Test
(
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  instancenbr INT64,
  altviolatorid INT64 NOT NULL,
  viol_invoice_id INT64 NOT NULL,
  invoice_date DATE NOT NULL,
  invoice_amount NUMERIC(33, 4) NOT NULL,
  invoice_amt_paid NUMERIC(33, 4),
  viol_inv_batch_id INT64 NOT NULL,
  viol_inv_status STRING NOT NULL,
  toll_due_amount NUMERIC(33, 4),
  fine_amount NUMERIC(33, 4),
  paid_amount NUMERIC(33, 4),
  viol_inv_status_descr STRING NOT NULL,
  invoice_status_date DATE NOT NULL
)
cluster by violatorid
;
