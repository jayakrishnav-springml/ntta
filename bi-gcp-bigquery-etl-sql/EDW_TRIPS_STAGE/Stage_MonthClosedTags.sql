## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/EDW_TRIPS_Stage_MonthClosedTags.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.MonthClosedTags
(
  src STRING NOT NULL,
  monthid INT64,
  histid INT64,
  custtagid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  tagagency STRING,
  tagid STRING,
  tagstatus STRING NOT NULL,
  tagstartdate DATETIME,
  tagenddate DATETIME,
  monthenddate DATETIME
)
;