CREATE OR REPLACE PROCEDURE EDW_TRIPS.Dim_Channel_Full_Load()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_Channel table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Ranjith		2020-10-01	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_Channel_Full_Load

EXEC Utility.FromLog 'dbo.Dim_Channel_Full_Load', 1
SELECT TOP 100 'dbo.Dim_Channel' Table_Name, * FROM  dbo.Dim_Channel ORDER BY 2
###################################################################################################################
*/

    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_Channel_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      Call EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
 		--=============================================================================================================
		-- Load dbo.Dim_Channel
		--=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_Channel;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_Channel CLUSTER BY ChannelID
        AS
          SELECT
              TollPlus_Channels.channelid AS channelid,
              TollPlus_Channels.channelname AS channelname,
              TollPlus_Channels.channeldesc AS channeldesc,
              TollPlus_Channels.isactive,
              TollPlus_Channels.isdisplay,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_Channels
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              0,
              0,
              current_datetime() 
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_Channel';
      Call EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      -- Table Swap Not Required as we are using Create or Replace in BQ
      --CALL EDW_TRIPS_utility.TableSwap('EDW_TRIPS.Dim_Channel_NEW', 'EDW_TRIPS.Dim_Channel');
      Call EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_Channel' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_Channel
        ORDER BY
          2 DESC
        LIMIT 1000
        ;
      END IF;

      -- Show results
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        Call EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        SELECT log_source,log_start_date;
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
    END;
/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_Channel_Load

EXEC Utility.FromLog 'dbo.Dim_Channel', 1
SELECT TOP 100 'dbo.Dim_Channel' Table_Name, * FROM dbo.Dim_Channel ORDER BY 2

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================


*/
END;