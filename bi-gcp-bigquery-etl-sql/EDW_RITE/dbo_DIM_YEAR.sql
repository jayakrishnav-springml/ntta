## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_YEAR.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Year
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
