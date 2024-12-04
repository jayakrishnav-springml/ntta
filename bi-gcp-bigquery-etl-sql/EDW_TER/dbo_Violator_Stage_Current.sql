CREATE TABLE IF NOT EXISTS EDW_TER.Violator_Stage_Current
(
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  current_ind INT64 NOT NULL
)
cluster by violatorid,vidseq
;