## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_MisClass_NEW.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_MisClass_NEW
(
  tptripid INT64 NOT NULL,
  tripwith STRING,
  exittripdatetime DATETIME,
  dayid INT64,
  tripidentmethodid INT64,
  laneid INT64,
  vehicleid INT64 NOT NULL,
  licenseplatenumber STRING,
  reportedvehicleclassid INT64 NOT NULL,
  mostfrequentvehicleclassid INT64,
  tollsdue NUMERIC(31, 2),
  lnd_updatedate DATETIME,
  edw_updatedate TIMESTAMP NOT NULL
)
cluster by tptripid
;