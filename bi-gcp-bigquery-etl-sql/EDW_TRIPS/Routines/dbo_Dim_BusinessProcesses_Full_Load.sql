CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Dim_BusinessProcesses_Full_Load`()
BEGIN
/*
IF OBJECT_ID ('dbo.Dim_BusinessProcesses_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Dim_BusinessProcesses_Load
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_BusinessProcesses table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	ARUN		2020-11-09	Created

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_BusinessProcesses_Full_Load

EXEC Utility.FromLog 'dbo.Dim_BusinessProcesses', 1
SELECT TOP 100 'dbo.Dim_BusinessProcesses' Table_Name, * FROM dbo.Dim_BusinessProcesses ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_BusinessProcesses_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    DECLARE row_count INT64;
    SET log_start_date = current_datetime('America/Chicago');
    
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL , NULL);
      
    --=============================================================================================================
		--  Load dbo.Dim_BusinessProcesses
		--=============================================================================================================
		
      -- DROP TABLE IF EXISTS EDW_TRIPS.Dim_BusinessProcesses_New;
      CREATE or REPLACE TABLE EDW_TRIPS.Dim_BusinessProcesses CLUSTER BY businessprocessid
        AS
          SELECT
              Finance_businessprocesses.businessprocessid,
              Finance_businessprocesses.businessprocesscode,
              Finance_businessprocesses.businessprocessdescription,
              Finance_businessprocesses.status,
              Finance_businessprocesses.isavailable,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.Finance_businessprocesses
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_BusinessProcesses';
      
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I',-1, NULL );

    -- Table swap!
    -- TableSwap is Not Required, using  Create or Replace Table 
    -- CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.dim_businessprocesses_new', 'EDW_TRIPS.dim_businessprocesses');
    
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL ,NULL);
    IF trace_flag = 1 THEN        
      SELECT 'EDW_TRIPS.Dim_BusinessProcesses' AS tablename,
          *
        FROM
          EDW_TRIPS.Dim_BusinessProcesses
      ORDER BY 2 DESC
      Limit 1000
      ;
    END IF;

    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL ,NULL );
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
    /*
--===============================================================================================================
##DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_BusinessProcesses_Load

EXEC Utility.FromLog 'dbo.Dim_BusinessProcesses', 1
SELECT TOP 100 'dbo.Dim_BusinessProcesses' Table_Name, * FROM dbo.Dim_BusinessProcesses ORDER BY 2


*/
    END;