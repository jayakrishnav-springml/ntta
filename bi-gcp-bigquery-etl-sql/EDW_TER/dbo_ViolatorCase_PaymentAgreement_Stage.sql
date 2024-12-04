CREATE TABLE IF NOT EXISTS EDW_TER.ViolatorCase_PaymentAgreement_Stage
(
  violatorid FLOAT64 NOT NULL,
  vidseq INT64 NOT NULL,
  settlementamount NUMERIC(33, 4),
  downpayment NUMERIC(33, 4),
  collections NUMERIC(33, 4),
  paidinfull INT64 NOT NULL,
  defaultind INT64 NOT NULL,
  adminfees NUMERIC(33, 4),
  citationfees NUMERIC(33, 4),
  monthlypaymentamount NUMERIC(33, 4),
  balancedue NUMERIC(33, 4)
)
cluster by vidseq
;