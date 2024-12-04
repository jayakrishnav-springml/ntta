## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Temp_TartTPTrip_BKUP_20221202.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.TartTPTrip_BKUP_20221202
(
  tartid INT64,
  tptripid INT64 NOT NULL,
  pmty_id INT64,
  txid_id INT64,
  level_0 STRING NOT NULL,
  violation_id INT64 NOT NULL,
  ttxn_id INT64 NOT NULL,
  earnedrev NUMERIC(31, 2),
  actualrev NUMERIC(31, 2),
  earned_axles INT64,
  actual_axles INT64,
  recordtype STRING NOT NULL,
  edw_updatedate DATETIME
)
;