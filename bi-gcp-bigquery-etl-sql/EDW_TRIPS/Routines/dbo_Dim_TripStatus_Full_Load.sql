CREATE OR REPLACE PROCEDURE EDW_TRIPS.Dim_TripStatus_Full_Load()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load Dim_TripStatus table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040134	Sagarika		2021-07-26	New!
CHG0041308	Shekhar			2022-08-04	Added a row for Unknown

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_TripStatus_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%dbo.Dim_TripStatus_Full_Load%' ORDER BY 1 DESC 
SELECT TOP 100 'dbo.Dim_TripStatus' Table_Name, * FROM dbo.Dim_TripStatus ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_TripStatus_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      ## SELECT log_source,log_start_date, 'Started full load' as log_message,'I', CAST(NULL as INT64), CAST(NULL as STRING);

    ########################################################################################################
		## Load dbo.Dim_TripStatus
		########################################################################################################
      -- DROP TABLE IF EXISTS EDW_TRIPS.dim_tripstatus_new;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_TripStatus CLUSTER BY tripstatusid
        AS
          SELECT
              coalesce(CAST( ts.tripstatusid as INT64), -1) AS tripstatusid,
              coalesce(CAST( ts.tripstatuscode as STRING), '') AS tripstatuscode,
              coalesce(CAST( ts.tripstatusdescription as STRING), '') AS tripstatusdesc,
              coalesce(CAST( ts.lnd_updatedate as DATETIME), DATETIME '1900-01-01 00:00:00') AS lnd_updatedate,
              coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_tripstatuses AS ts
          UNION DISTINCT
          SELECT
              -1,
              'Unknown',
              'Unknown',
              current_datetime(),
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.TripStatus';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      ## SELECT log_source,log_start_date,log_message,'I', -1, CAST(NULL as STRING);
      ## COLLECT STATISTICS is not supported in this dialect.
      
      ## SET log_message = 'Created STATISTICS on dbo.Dim_TripStatus_NEW';
      ## CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      ## CALL EDW_TRIPS_SUPPORT.TableSwap('dbo.Dim_TripStatus_NEW', 'dbo.Dim_TripStatus');
      ## SET log_message = 'Completed dbo.Dim_TripStatus table swap';
      ## CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));


      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      ## SELECT log_source, log_start_date, 'Completed full load' as log_message,'I', CAST(NULL as INT64), CAST(NULL as STRING);
      ## Show results
      IF trace_flag = 1 THEN
         ## CALL EDW_TRIPS_SUPPORT.FromLog(log_source, substr(CAST(log_start_date as STRING), 1, 23));
         SELECT log_source,log_start_date;
       END IF;
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_TripStatus' AS tablename,
            *
          FROM
            EDW_TRIPS.dim_tripstatus
         
        ORDER BY 2 DESC
        LIMIT 1000
        ;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        ## SELECT log_source, log_start_date, error_message,'E', CAST(NULL as INT64), CAST(NULL as STRING);
        ## CALL EDW_TRIPS_SUPPORT.FromLog(`@log_source`, `@log_start_date`);
        SELECT log_source,log_start_date;
        RAISE USING MESSAGE = error_message;
      END;
    END;
  /*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_TripStatus_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%dbo.Dim_TripStatus_Full_Load%' ORDER BY 1 DESC 
SELECT TOP 100 'dbo.Dim_TripStatus' Table_Name, * FROM dbo.Dim_TripStatus ORDER BY 2
--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================


*/
  END;