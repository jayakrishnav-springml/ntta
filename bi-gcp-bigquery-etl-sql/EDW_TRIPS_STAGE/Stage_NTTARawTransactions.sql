## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_NTTARawTransactions.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.NTTARawTransactions
(
  tptripid INT64 NOT NULL,
  sourcetripid INT64,
  tripdayid INT64 NOT NULL,
  tripdate DATETIME,
  sourceofentry INT64,
  recordtype STRING,
  violationserialnumber INT64,
  vestimestamp DATETIME,
  localvestimestamp DATETIME,
  laneid INT64,
  facilitycode STRING,
  plazacode STRING,
  lanenumber INT64,
  vehiclespeed INT64,
  revenuevehicleclass INT64,
  lanetagstatus INT64,
  fareamount NUMERIC(31, 2),
  lnd_updatedate DATETIME,
  edw_updatedate DATETIME
)
;