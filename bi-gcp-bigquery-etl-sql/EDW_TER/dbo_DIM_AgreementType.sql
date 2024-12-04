CREATE TABLE IF NOT EXISTS EDW_TER.Dim_AgreementType
(
  agreementtypeid INT64 NOT NULL,
  agreementtype STRING NOT NULL,
  insert_datetime DATETIME NOT NULL
)
cluster by agreementtypeid
;