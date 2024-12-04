## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_DayCountRange.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_DayCountRange
(
  daycountid INT64,
  dayrangeid INT64 NOT NULL,
  dayrangedesc STRING NOT NULL,
  dayrangestart INT64 NOT NULL,
  dayrangeend INT64 NOT NULL,
  edw_updatedate TIMESTAMP NOT NULL
)
CLUSTER BY daycountid
;