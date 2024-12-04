CREATE TABLE IF NOT EXISTS EDW_TER.ViolatorStatus_Mart_Incr_Stage
(
  reportdate DATE,
  violatorid INT64,
  vidseq INT64,
  termaddedflag INT64 NOT NULL,
  termremovedflag INT64 NOT NULL,
  hvactiveadded INT64 NOT NULL,
  hvactiveremoved INT64 NOT NULL,
  vrbflagadded INT64 NOT NULL,
  vrbflagremoved INT64 NOT NULL
)
cluster by violatorid,vidseq
;
