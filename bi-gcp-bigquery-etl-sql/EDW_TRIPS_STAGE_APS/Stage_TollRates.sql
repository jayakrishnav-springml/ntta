## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_TollRates.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.TollRates
(
  entryplazaid INT64,
  exitplazaid INT64,
  exitlaneid INT64 NOT NULL,
  lanetype STRING NOT NULL,
  starteffectivedate DATETIME NOT NULL,
  endeffectivedate DATETIME NOT NULL,
  vehicleclass STRING,
  scheduletype STRING,
  fromtime NUMERIC(31, 2),
  totime NUMERIC(31, 2),
  tagfare NUMERIC(31, 2),
  platefare NUMERIC(31, 2)
)CLUSTER BY exitlaneid
;