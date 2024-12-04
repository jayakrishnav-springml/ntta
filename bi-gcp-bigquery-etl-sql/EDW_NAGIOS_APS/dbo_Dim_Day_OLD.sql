-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/dbo_Dim_Day_OLD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS_APS.Dim_Day_Old
(
  dayid INT64,
  daydate DATE,
  daydesc STRING,
  dayname STRING,
  dayofmonth INT64,
  dayofyear INT64,
  isweekday INT64,
  isweekend INT64,
  isbusinessday INT64,
  isholiday INT64,
  holidayname STRING,
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
  p1dayid INT64,
  p2dayid INT64,
  p3dayid INT64,
  p4dayid INT64,
  p5dayid INT64,
  p6dayid INT64,
  p7dayid INT64,
  p1weekid INT64,
  p2weekid INT64,
  p3weekid INT64,
  p4weekid INT64,
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
cluster by dayid
;
