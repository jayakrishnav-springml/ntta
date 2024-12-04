## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_WEEK.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Week
(
  weekid INT64,
  weekdate DATE,
  weekdesc STRING,
  weekofyear INT64,
  monthid INT64,
  quarterid INT64,
  yearid INT64
)
cluster by weekid
;
