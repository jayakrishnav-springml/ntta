## Translation time: 2024-03-06T09:59:19.729172Z
## Translation job ID: 41d16c65-5f33-417b-8c07-cb221ef773e0
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Views/Utility_vw_FullLoadTracker.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE OR REPLACE VIEW LND_TBOS_SUPPORT.vw_FullLoadTracker
AS
  SELECT
    p.databasename,
    logsource AS tablename,
    row_count,
    proctime AS fullloadruntime,
    procstartdate AS loadstartdate,
    logdate AS loadfinishdate
  FROM LND_TBOS_SUPPORT.processlog AS l
    INNER JOIN LND_TBOS_SUPPORT.tableloadparameters AS
     p ON l.logsource = p.fullname
  WHERE logmessage = 'Step 2: SSIS load Finished'
    AND EXISTS (
    SELECT
      1
    FROM
      LND_TBOS_SUPPORT.tableloadparameters AS p_0
    WHERE p_0.fullname = l.logsource
      AND p_0.cdcflag = 1
      AND p_0.active = 1
  )
;
