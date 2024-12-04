CREATE TABLE IF NOT EXISTS EDW_TER.ViolatorCase_Bankruptcy_Stage
(
  violatorid FLOAT64 NOT NULL,
  vidseq INT64 NOT NULL,
  excusedamount NUMERIC(33, 4),
  collectableamount NUMERIC(33, 4),
  bankruptcyind INT64 NOT NULL
)
cluster by vidseq
;