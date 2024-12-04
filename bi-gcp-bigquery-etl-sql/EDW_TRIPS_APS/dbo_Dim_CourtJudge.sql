## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_CourtJudge.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_CourtJudge
(
  judgeid INT64 NOT NULL,
  courtid INT64 NOT NULL,
  lastname STRING NOT NULL,
  firstname STRING NOT NULL,
  starteffectivedate TIMESTAMP NOT NULL,
  endeffectivedate TIMESTAMP,
  createddate TIMESTAMP NOT NULL,
  lnd_updatedate TIMESTAMP,
  edw_updatedate DATETIME
)
CLUSTER BY judgeid
;