CREATE OR REPLACE PROCEDURE LND_TBOS_SUPPORT.ToSSIS(logsource STRING, procstartdate DATETIME, logmessage STRING, logtype STRING, row_count INT64, step STRING)
BEGIN
/*
USE LND_TBOS
GO
IF OBJECT_ID ('Utility.ToSSIS', 'P') IS NOT NULL DROP PROCEDURE Utility.ToSSIS
GO
###################################################################################################################
Purpose: Log ETL process execution details in Utility.ProcessLog table. 
-------------------------------------------------------------------------------------------------------------------
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837	Andy and Shankar		2020-08-20	New!
-------------------------------------------------------------------------------------------------------------------
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.ToSSIS 'dbo.Dim_CollectionStatus', '2020-08-20 10:46:29.193', 'Started full load', 'I', NULL, 'Step:1'
SELECT TOP 100 * FROM Utility.ProcessLog ORDER BY 1 DESC
###################################################################################################################
*/

    DECLARE logdate DATETIME DEFAULT current_datetime();
    
    ## Commenting To_Log Call and Putting To_Log Details into select Query to Print Log Details While Execution 
    ## CALL LND_TBOS_SUPPORT.tolog(logsource, procstartdate, logmessage, logtype, row_count, CAST(NULL as STRING));
    Select logsource , procstartdate , logmessage, logtype, row_count, CAST(NULL as STRING);
    INSERT INTO LND_TBOS_SUPPORT.SSISLoadCheck (loaddate, loadsource, loadstep, loadinfo, row_count)
      VALUES (logdate, substr(logsource,1,100), substr(step,1,10), substr(logmessage,1,400), row_count);
  END;