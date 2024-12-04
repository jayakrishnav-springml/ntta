CREATE TABLE IF NOT EXISTS EDW_TER.Violator_PaymentAgreement_Current_With_Other_Violatorids_Test
(
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  instancenbr INT64,
  altviolatorid INT64
)
cluster by violatorid,vidseq
;