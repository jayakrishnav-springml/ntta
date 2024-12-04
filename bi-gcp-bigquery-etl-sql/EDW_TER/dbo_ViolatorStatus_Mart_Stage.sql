CREATE TABLE IF NOT EXISTS  EDW_TER.ViolatorStatus_Mart_Stage
(
  reportdate DATE,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  hvflag INT64 NOT NULL,
  hvexemptflag INT64 NOT NULL,
  termflag INT64 NOT NULL,
  eligrmdyflag INT64 NOT NULL,
  banflag INT64 NOT NULL,
  bancitewarnflag INT64 NOT NULL,
  banimpoundflag INT64 NOT NULL,
  vrbflag INT64 NOT NULL,
  determinationletterflag INT64 NOT NULL,
  banletterflag INT64 NOT NULL,
  termletterflag INT64 NOT NULL,
  bankruptcyind INT64,
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
