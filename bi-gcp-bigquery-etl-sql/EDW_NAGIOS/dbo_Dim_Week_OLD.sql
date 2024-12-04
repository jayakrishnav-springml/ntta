-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/dbo_Dim_Week_OLD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS.Dim_Week_Old
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
