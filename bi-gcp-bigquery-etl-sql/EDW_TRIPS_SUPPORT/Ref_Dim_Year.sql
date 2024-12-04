## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Ref_Dim_Year.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Dim_Year
(
  cal_yearid INT64 NOT NULL,
  fiscal_yearid INT64 NOT NULL,
  year_desc INT64,
  yeardate DATE,
  yearduration INT64,
  cal_prevyearid INT64,
  cal_prev2yearid INT64,
  cal_prev3yearid INT64,
  cal_prev4yearid INT64,
  cal_prev5yearid INT64,
  cal_prev6yearid INT64,
  cal_prev7yearid INT64
)
;