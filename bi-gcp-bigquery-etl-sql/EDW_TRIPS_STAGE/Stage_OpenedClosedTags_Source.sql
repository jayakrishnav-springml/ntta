## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/EDW_TRIPS_Stage_OpenedClosedTags_Source.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.OpenedClosedTags_Source
(
  monthid INT64,
  src STRING NOT NULL,
  histid INT64,
  custtagid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  tagagency STRING,
  tagid STRING,
  tagstatus STRING NOT NULL,
  tagstartdate DATETIME,
  tagenddate DATETIME,
  tagstatus_lag STRING,
  change_num INT64,
  change_num_seq INT64,
  dataintegrityissue STRING,
  edw_updatedate DATETIME
)
;