## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/EDW_TRIPS_Stage_CustomerTags_Source.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.CustomerTags_Source
(
  src STRING NOT NULL,
  histid INT64,
  custtagid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  accountstatusdesc STRING NOT NULL,
  tagagency STRING,
  tagid STRING,
  tagstatus STRING,
  tagstartdate DATETIME NOT NULL,
  tagenddate DATETIME NOT NULL,
  dataintegrityissue STRING,
  tagassigneddate DATETIME,
  tagassignedenddate DATETIME,
  tagstatusdate DATETIME,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  createddate DATETIME NOT NULL,
  createduser STRING,
  tagtype STRING,
  tagalias STRING,
  returnedorassignedtype STRING,
  itemcode STRING,
  isnonrevenue INT64,
  specialitytag STRING,
  mounting STRING,
  channelid INT64,
  accountopendate DATETIME,
  accountlastactivedate DATETIME,
  accountlastclosedate DATETIME,
  edw_updatedate DATETIME
)
cluster by customerid
;