
CREATE or REPLACE  PROCEDURE EDW_TRIPS.Dim_POSLocation_Full_Load() 
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_POSLocation table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038749	  Gouthami		2021-04-27		New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_POSLocation_Full_Load

EXEC Utility.FromLog 'dbo.Dim_POSLocation_Full_Load', 1
SELECT TOP 100 'dbo.Dim_POSLocation' Table_Name, * FROM  dbo.Dim_POSLocation ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_POSLocation_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0; -- Testing
    BEGIN 
        DECLARE row_count INT64;

        SET log_start_date = current_datetime('America/Chicago');
        CALL  EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);
        --=============================================================================================================
        -- Load dbo.Dim_POSLocation
        --=============================================================================================================


        CREATE OR REPLACE  TABLE EDW_TRIPS.Dim_POSLocation CLUSTER BY posid AS 
        SELECT
            OPERATIONALLOCATIONS.operationallocationid AS posid,
            OPERATIONALLOCATIONS.locationname AS posname,
            OPERATIONALLOCATIONS.locationcode AS poscode,
            OPERATIONALLOCATIONS.locationdesc AS posdesc,
            OPERATIONALLOCATIONS.address1,
            OPERATIONALLOCATIONS.city,
            OPERATIONALLOCATIONS.state,
            OPERATIONALLOCATIONS.zipcode,
            OPERATIONALLOCATIONS.locationtype,
            current_datetime() AS edw_updatedate
        FROM
            LND_TBOS.TollPlus_OPERATIONALLOCATIONS  AS OPERATIONALLOCATIONS
        UNION
        ALL
        SELECT
            -1,
            'Unknown',
            'Unknown',
            'Unknown',
            'Unknown',
            'Unknown',
            'Unknown',
            'Unknown',
            'Unknown',
            current_datetime();

        SET log_message = 'Loaded EDW_TRIPS.Dim_POSLocation';
        CALL  EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);

        -- Table swap!

        --CALL Utility.TableSwap('EDW_TRIPS.Dim_POSLocation_NEW', 'EDW_TRIPS.Dim_POSLocation');
        CALL  EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
    
        IF trace_flag = 1 THEN
            SELECT
                'EDW_TRIPS.Dim_POSLocation' AS tablename,
                *
            FROM
                EDW_TRIPS.Dim_POSLocation
            ORDER BY 2 DESC
            LIMIT
                1000;
        END IF;
        EXCEPTION WHEN ERROR THEN
            BEGIN 
                DECLARE error_message STRING DEFAULT @@error.message;
                CALL  EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
                RAISE USING MESSAGE = error_message; -- Rethrow the error
        END;

    END;
/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_POSLocation_Load

EXEC Utility.FromLog 'dbo.Dim_POSLocation', 1
SELECT TOP 100 'dbo.Dim_POSLocation' Table_Name, * FROM dbo.Dim_POSLocation ORDER BY 2

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================


*/

END;
