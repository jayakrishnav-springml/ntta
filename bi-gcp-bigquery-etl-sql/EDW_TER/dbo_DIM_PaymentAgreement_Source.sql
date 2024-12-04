CREATE TABLE IF NOT EXISTS EDW_TER.Dim_PaymentAgreement_Source
(
  paymentagreement_sourceid INT64 NOT NULL,
  paymentagreement_source STRING NOT NULL,
  insert_datetime DATETIME NOT NULL
)
cluster by paymentagreement_sourceid
;