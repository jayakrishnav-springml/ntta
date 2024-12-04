CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Dim_PmCaseType_Full_Load`()
BEGIN
/*
IF OBJECT_ID ('dbo.Dim_PmCaseType_Full_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Dim_PmCaseType_Full_Load
####################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_PmCaseType table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
	Gouthami		2024-09-09	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_PmCaseType_Full_Load 

EXEC Utility.FromLog 'dbo.Dim_PmCaseType', 1
SELECT TOP 100 'dbo.Dim_PmCaseType' Table_Name, * FROM dbo.Dim_PmCaseType ORDER BY 2
####################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_PmCaseType_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;-- Testing
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      
      --=============================================================================================================
      -- Load dbo.Dim_PmCaseType
      --=============================================================================================================
      
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_PmCaseType CLUSTER BY casetypeid as (
      select casetypeid,
             casetype,
             casetypedesc,
             updateddate,
             lnd_updatedate,
             coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate
      from `LND_TBOS.CaseManager_PmCaseTypes`
      UNION ALL
      SELECT
              -1,
              'Unknown',
              'Unknown',
              'Unknown',
              'Unknown',
               current_datetime() AS edw_updatedate
      );
      SET log_message = 'Loaded dbo.Dim_PmCaseType';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      -- Table swap!
      --using create and replace in bigquery
      --CALL EDW_TRIPS_utility.TableSwap('EDW_TRIPS.Dim_PmCaseType_NEW', 'EDW_TRIPS.Dim_PmCaseType');
      
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      -- Show results
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_PmCaseType' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_PmCaseType
        ORDER BY 2 DESC 
        LIMIT 1000;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        --CALL utility.fromlog(log_source, log_start_date);
        SELECT log_source,log_start_date;
        RAISE USING MESSAGE = error_message;
        -- Rethrow the error!
      END;
    /*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_PmCaseType_Full_Load

EXEC Utility.FromLog 'dbo.Dim_PmCaseType', 1
SELECT TOP 100 'dbo.Dim_PmCaseType' Table_Name, * FROM dbo.Dim_PmCaseType ORDER BY 2

*/
    END;
  END;