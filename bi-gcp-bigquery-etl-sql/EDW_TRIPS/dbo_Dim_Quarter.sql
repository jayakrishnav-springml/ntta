## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_Quarter.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS.Dim_Quarter
(
  quarterid INT64,
  quarterbegindate DATE,
  quarterenddate DATE,
  yearquarterdesc STRING,
  quarteryeardesc STRING,
  quarterdesc STRING,
  quarterduration INT64,
  yearid INT64,
  yearbegindate DATE,
  yearduration INT64,
  p1quarterid INT64,
  p2quarterid INT64,
  p3quarterid INT64,
  p4quarterid INT64,
  ly1quarterid INT64,
  p1yearid INT64,
  p2yearid INT64,
  p3yearid INT64,
  p4yearid INT64,
  p5yearid INT64,
  p6yearid INT64,
  p7yearid INT64,
  lastmodified DATETIME NOT NULL
)
CLUSTER BY quarterid
;