CREATE TABLE IF NOT EXISTS EDW_TER.Violator_PaymentPlan_Xref
(
  paymentplanid INT64 NOT NULL,
  violatorid INT64,
  vidseq INT64,
  paymentplanviolatorseq INT64 NOT NULL,
  deletedflag INT64 NOT NULL,
  paymentplanstatus INT64 NOT NULL
)
;