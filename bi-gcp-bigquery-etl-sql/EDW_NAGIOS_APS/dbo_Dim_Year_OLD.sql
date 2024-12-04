-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/dbo_Dim_Year_OLD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS_APS.Dim_Year_Old
(
  yearid INT64 NOT NULL,
  yearbegindate DATE,
  yearduration INT64,
  p1yearid INT64,
  p2yearid INT64,
  p3yearid INT64,
  p4yearid INT64,
  p5yearid INT64,
  p6yearid INT64,
  p7yearid INT64,
  lastmodified DATETIME NOT NULL
)
cluster by yearid
;
