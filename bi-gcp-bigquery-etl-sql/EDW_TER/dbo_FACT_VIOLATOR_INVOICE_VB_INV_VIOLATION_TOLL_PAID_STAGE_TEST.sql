CREATE TABLE IF NOT EXISTS  EDW_TER.Fact_Violator_Invoice_Vb_Inv_Violation_Toll_Paid_Stage_Test
(
  violator_id INT64,
  vbi_invoice_id INT64 NOT NULL,
  toll_paid BIGNUMERIC(40, 2)
)
cluster by violator_id,vbi_invoice_id
;
