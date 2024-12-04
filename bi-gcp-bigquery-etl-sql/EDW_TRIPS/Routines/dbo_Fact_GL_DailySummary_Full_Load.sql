CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_GL_DailySummary_Full_Load`()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_GL_DailySummary table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0000000	Gouthami		YYYY-MM-DD	New!

CHG0038040  Arun Krishna 2021-01-27 -- Added Delete Flag 

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_GL_DailySummary_Full_Load

EXEC Utility.FromLog 'dbo.Fact_GL_DailySummary', 1
SELECT TOP 100 'dbo.Fact_GL_DailySummary' Table_Name, * FROM dbo.Fact_GL_DailySummary ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_GL_DailySummary_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;

    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);
      
      --=============================================================================================================
      -- Load dbo.Fact_GL_DailySummary
      --=============================================================================================================
				
      --DROP TABLE IF EXISTS EDW_TRIPS.Fact_GL_DailySummary_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_GL_DailySummary
      CLUSTER BY DailySummaryID
        AS
          SELECT
              Finance_GLDailySummaryByCoaIDBuID.dailysummaryid,
              Finance_GLDailySummaryByCoaIDBuID.chartofaccountid,
              Finance_GLDailySummaryByCoaIDBuID.businessunitid,
              Finance_GLDailySummaryByCoaIDBuID.beginningbal,
              Finance_GLDailySummaryByCoaIDBuID.endingbal,
              Finance_GLDailySummaryByCoaIDBuID.debittxnamount,
              Finance_GLDailySummaryByCoaIDBuID.credittxnamount,
              CAST(Finance_GLDailySummaryByCoaIDBuID.posteddate as DATE) AS posteddate,
              CAST(Finance_GLDailySummaryByCoaIDBuID.jobrundate as DATE) AS jobrundate,
              Finance_GLDailySummaryByCoaIDBuID.fiscalyearname,
              Finance_GLDailySummaryByCoaIDBuID.createddate,
              Finance_GLDailySummaryByCoaIDBuID.createduser,
              Finance_GLDailySummaryByCoaIDBuID.updateddate,
              Finance_GLDailySummaryByCoaIDBuID.updateduser,
              CASE
                WHEN Finance_GLDailySummaryByCoaIDBuID.lnd_updatetype = 'D' THEN 1
                ELSE 0
              END AS deleteflag,
              Finance_GLDailySummaryByCoaIDBuID.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.Finance_GLDailySummaryByCoaIDBuID
            WHERE Finance_GLDailySummaryByCoaIDBuID.lnd_updatetype <> 'D'
      ;
      SET log_message = 'Loaded EDW_TRIPS.Fact_GL_DailySummary';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      --Table swap!
      --TableSwap is Not Required, using Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Fact_GL_DailySummary_NEW', 'EDW_TRIPS.Fact_GL_DailySummary');
      --CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
	    --Show results
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_GL_DailySummary' AS tablename,
            *
          FROM
            EDW_TRIPS.Fact_GL_DailySummary
        ORDER BY
          2 DESC
        LIMIT 1000
        ;
      END IF;
  
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        RAISE USING MESSAGE = error_message;
      END;
    END;
  /*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
EXEC dbo.Fact_GL_DailySummary_Full_Load

EXEC Utility.FromLog 'dbo.Fact_GL_DailySummary', 1
SELECT TOP 100 'dbo.Fact_GL_DailySummary' Table_Name, * FROM dbo.Fact_GL_DailySummary ORDER BY 2

--===============================================================================================================
-- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
--===============================================================================================================


*/


END;