## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/EDW_TRIPS_Stage_RebillHistory.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.RebillHistory
(
  src STRING NOT NULL,
  histid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  autoreplenishmentid INT64,
  rebillamount NUMERIC(31, 2),
  updateddate DATETIME NOT NULL
)
cluster by customerid
;