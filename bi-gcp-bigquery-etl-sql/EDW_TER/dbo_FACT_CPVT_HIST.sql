CREATE TABLE IF NOT EXISTS EDW_TER.Fact_Cpvt_Hist
(
  partition_date INT64 NOT NULL,
  paymentplanid INT64,
  monthid INT64,
  vtolls BIGNUMERIC(40, 2),
  tolltxns BIGNUMERIC(40, 2),
  paymentcommitments NUMERIC(33, 4),
  dollarscollected BIGNUMERIC(40, 2)
)
;
