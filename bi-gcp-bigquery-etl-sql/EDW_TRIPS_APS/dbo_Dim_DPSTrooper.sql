## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_DPSTrooper.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_DPSTrooper
(
  dpstrooperid INT64 NOT NULL,
  firstname STRING NOT NULL,
  lastname STRING NOT NULL,
  area STRING,
  district STRING,
  idnumber INT64,
  region STRING,
  channelid INT64,
  icnid INT64,
  troopersignatureimage STRING,
  isactive INT64,
  filepathconfigurationid INT64,
  createddate TIMESTAMP NOT NULL,
  lnd_updatedate TIMESTAMP,
  edw_updatedate DATETIME
)
CLUSTER BY  dpstrooperid
;