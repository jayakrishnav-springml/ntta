## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_Agency.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_Agency
(
  agencyid INT64 NOT NULL,
  agencytype STRING NOT NULL,
  agencyname STRING,
  agencycode STRING NOT NULL,
  agencystartdate DATETIME,
  agencyenddate DATETIME,
  lnd_updateddate DATETIME,
  edw_updateddate TIMESTAMP NOT NULL
)
CLUSTER BY agencyid
;