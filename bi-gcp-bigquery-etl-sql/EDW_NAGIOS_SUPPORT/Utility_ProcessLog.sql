-- Translation time: 2024-03-04T06:55:00.172408Z
-- Translation job ID: d5470d38-a22e-41f0-932c-1daeb0fa8d4c
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_NAGIOS/Tables/Utility_ProcessLog.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_NAGIOS_SUPPORT.ProcessLog
(
  logdate DATETIME NOT NULL,
  logsource STRING NOT NULL,
  logmessage STRING NOT NULL,
  logtype STRING NOT NULL,
  row_count INT64,
  proctime STRING,
  querytime STRING,
  proctimeinsec NUMERIC(32, 3),
  querytimeinsec NUMERIC(32, 3),
  procstartdate DATETIME,
  querysubmitdate DATETIME,
  queryenddate DATETIME,
  sessionid STRING,
  queryid STRING,
  query STRING,
  resourceclass STRING
)
cluster by logdate
;
