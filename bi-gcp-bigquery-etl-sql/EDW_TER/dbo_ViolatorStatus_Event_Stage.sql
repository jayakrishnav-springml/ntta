CREATE TABLE IF NOT EXISTS EDW_TER.ViolatorStatus_Event_Stage
(
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  hvactive INT64,
  hvremoved INT64,
  vrbacknowledged INT64,
  vrbremoved INT64,
  vrbremovalqueued INT64,
  banbyprocessserver INT64,
  banbydps INT64,
  banbyusmail1stban INT64
)
cluster by violatorid,vidseq
;
