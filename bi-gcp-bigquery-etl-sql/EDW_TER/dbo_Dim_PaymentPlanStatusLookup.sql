CREATE TABLE IF NOT EXISTS EDW_TER.Dim_PaymentPlanStatusLookup
(
  paymentplanstatuslookupid INT64 NOT NULL,
  descr STRING NOT NULL,
  activeflag INT64 NOT NULL,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL
)
cluster by paymentplanstatuslookupid
;