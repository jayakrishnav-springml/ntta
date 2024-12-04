-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/dbo_Dim_Month.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS.Dim_Month
(
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
  p1monthid INT64,
  p2monthid INT64,
  p3monthid INT64,
  p4monthid INT64,
  p5monthid INT64,
  p6monthid INT64,
  p7monthid INT64,
  p8monthid INT64,
  p9monthid INT64,
  p10monthid INT64,
  p11monthid INT64,
  p12monthid INT64,
  ly1monthid INT64,
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
cluster by monthid
;
