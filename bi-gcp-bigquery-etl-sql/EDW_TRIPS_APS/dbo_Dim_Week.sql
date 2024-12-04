## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Dim_Week.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Dim_Week
(
  weekid INT64,
  weekbegindate DATE,
  weekenddate DATE,
  weekdesc STRING,
  weekofyear INT64,
  monthid INT64 NOT NULL,
  monthbegindate DATE,
  monthenddate DATE,
  yearmonthdesc STRING,
  monthyeardesc STRING,
  monthdesc STRING,
  monthofyear INT64,
  monthduration INT64,
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
  p1weekid INT64,
  p2weekid INT64,
  p3weekid INT64,
  p4weekid INT64,
  lastmodified DATETIME NOT NULL
)
cluster by weekid
;