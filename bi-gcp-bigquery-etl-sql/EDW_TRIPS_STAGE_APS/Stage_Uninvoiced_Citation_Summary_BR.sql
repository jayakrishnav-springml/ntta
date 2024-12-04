## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_Uninvoiced_Citation_Summary_BR.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE_APS.Uninvoiced_Citation_Summary_BR
(
  customerid INT64 NOT NULL,
  tptripid INT64 NOT NULL,
  citationid INT64 NOT NULL,
  tripstatuscode STRING,
  posteddate DATETIME,
  tollamount NUMERIC(31, 2) NOT NULL,
  businessrulematchedflag INT64
)CLUSTER BY citationid
;