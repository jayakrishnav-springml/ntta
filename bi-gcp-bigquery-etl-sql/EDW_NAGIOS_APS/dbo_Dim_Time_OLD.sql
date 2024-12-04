-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/dbo_Dim_Time_OLD.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS_APS.Dim_Time_Old
(
  timeid INT64 NOT NULL,
  hour STRING NOT NULL,
  minute STRING NOT NULL,
  second STRING NOT NULL,
  `12_hour` STRING NOT NULL,
  am_pm STRING NOT NULL,
  `5_minute` STRING NOT NULL,
  `10_minute` STRING NOT NULL,
  `15_minute` STRING NOT NULL,
  `30_minute` STRING NOT NULL,
  lastmodified DATETIME NOT NULL
)
cluster by timeid
;
