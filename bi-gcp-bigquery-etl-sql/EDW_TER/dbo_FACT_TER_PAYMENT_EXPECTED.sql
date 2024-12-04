CREATE TABLE IF NOT EXISTS EDW_TER.Fact_Ter_Payment_Expected
(
  paymentplanid INT64 NOT NULL,
  monthid INT64 NOT NULL,
  downpayment NUMERIC(33, 4) NOT NULL,
  monthlypayment NUMERIC(33, 4) NOT NULL
)
;