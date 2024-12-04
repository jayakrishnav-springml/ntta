CREATE TABLE IF NOT EXISTS EDW_TER.ViolatorStatus_Mart
(
  reportdate DATE NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  hvflag INT64 NOT NULL,
  hvexemptflag INT64 NOT NULL,
  termflag INT64 NOT NULL,
  termaddedflag INT64,
  termremovedflag INT64,
  eligrmdyflag INT64 NOT NULL,
  banflag INT64 NOT NULL,
  bancitewarnflag INT64 NOT NULL,
  banimpoundflag INT64 NOT NULL,
  vrbflag INT64 NOT NULL,
  vrbflagadded INT64,
  vrbflagremoved INT64,
  determinationletterflag INT64 NOT NULL,
  banletterflag INT64 NOT NULL,
  termletterflag INT64 NOT NULL,
  hvactive INT64,
  hvactiveadded INT64,
  hvactiveremoved INT64,
  hvremoved INT64,
  vrbacknowledged INT64,
  vrbremoved INT64,
  vrbremovalqueued INT64,
  banbyprocessserver INT64,
  banbydps INT64,
  banbyusmail1stban INT64
)
cluster by reportdate,violatorid,vidseq
;