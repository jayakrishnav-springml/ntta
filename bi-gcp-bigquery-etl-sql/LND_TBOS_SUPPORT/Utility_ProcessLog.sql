## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Utility_ProcessLog.sql
## Translated from: SqlServer
## Translated to: BigQuery


CREATE TABLE IF NOT EXISTS LND_TBOS_SUPPORT.ProcessLog
(
  logdate DATETIME NOT NULL,
  logsource STRING NOT NULL ,
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
) cluster by logdate
;