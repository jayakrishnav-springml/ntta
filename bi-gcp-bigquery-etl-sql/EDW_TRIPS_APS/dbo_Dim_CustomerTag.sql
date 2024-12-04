## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_CustomerTag.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_CustomerTag
(
  custtagid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  tagid STRING NOT NULL,
  channelid INT64 NOT NULL,
  tagagency STRING,
  tagtype STRING NOT NULL,
  tagstatus STRING NOT NULL,
  tagstatusstartdate DATE NOT NULL,
  tagstatusenddate DATE NOT NULL,
  tagassigneddate DATE NOT NULL,
  tagassignedenddate DATE NOT NULL,
  itemcode STRING,
  mounting STRING,
  specialitytag STRING,
  nonrevenueflag INT64 NOT NULL,
  updateddate DATETIME NOT NULL,
  lnd_updatedate DATETIME NOT NULL,
  edw_updatedate DATETIME
)
CLUSTER BY custtagid
;