-- Translation time: 2024-03-04T06:57:31.196697Z
-- Translation job ID: 836e6d48-0b9e-4fef-8f0f-6740565861eb
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_NAGIOS/Tables/Utility_ProcessLog.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_NAGIOS_SUPPORT.ProcessLog
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
