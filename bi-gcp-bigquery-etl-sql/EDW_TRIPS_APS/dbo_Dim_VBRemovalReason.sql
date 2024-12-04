## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_VBRemovalReason.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_VBRemovalReason
(
  vbremovalreasonid INT64 NOT NULL,
  vbremovalreasoncode STRING NOT NULL,
  vbremovalreasondescription STRING,
  parentstatusid INT64,
  activeflag INT64 NOT NULL,
  detaileddesc STRING,
  createddate TIMESTAMP,
  lnd_updatedate TIMESTAMP,
  edw_updatedate DATETIME
)
cluster by vbremovalreasonid
;