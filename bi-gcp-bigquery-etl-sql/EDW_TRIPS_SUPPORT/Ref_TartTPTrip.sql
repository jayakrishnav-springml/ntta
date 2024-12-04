## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_TartTPTrip.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.TartTPTrip
(
  tartid NUMERIC(29),
  tptripid INT64 NOT NULL,
  tripdayid INT64 NOT NULL,
  pmty_id NUMERIC(29),
  txid_id NUMERIC(29),
  level_0 STRING NOT NULL,
  violation_id BIGNUMERIC(48, 10) NOT NULL,
  ttxn_id INT64 NOT NULL,
  earnedrev NUMERIC(31, 2),
  actualrev NUMERIC(31, 2),
  earned_axles INT64,
  actual_axles INT64,
  sourceofentry INT64,
  recordtype STRING,
  edw_updatedate DATETIME
)
;