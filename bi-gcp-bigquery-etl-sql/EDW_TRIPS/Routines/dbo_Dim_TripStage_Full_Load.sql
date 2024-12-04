CREATE OR REPLACE PROCEDURE EDW_TRIPS.Dim_TripStage_Full_Load()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load Dim_TripStage table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040134	Sagarika		2021-07-26	New!
CHG0041308	Shekhar			Added a row for Unknown

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_TripStage_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%dbo.Dim_TripStage%' ORDER BY 1 DESC 
SELECT TOP 100 'dbo.Dim_TripStage' Table_Name, * FROM dbo.Dim_TripStage ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_TripStage_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      ## SELECT log_source, log_start_date, 'Started full load' as log_message,'I', CAST(NULL as INT64), CAST(NULL as STRING);
    ##########################################################################################################
		## Load dbo.Dim_TripStages
		##########################################################################################################
      -- DROP TABLE IF EXISTS EDW_TRIPS.dim_tripstage_new;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_TripStage CLUSTER BY tripstageid
        AS
          SELECT
              coalesce(CAST( tt.tripstageid as INT64), -1) AS tripstageid,
              coalesce(CAST( tt.tripstagecode as STRING), '') AS tripstagecode,
              coalesce(CAST( tt.tripstagedescription as STRING), '') AS tripstagedesc,
              coalesce(CAST( tt.parentstageid as INT64), -1) AS parentstageid,
              coalesce(CAST( tt.updateddate as DATETIME), DATETIME '1900-01-01 00:00:00') AS updateddate,
              coalesce(CAST( tt.lnd_updatedate as DATETIME), DATETIME '1900-01-01 00:00:00') AS lnd_updatedate,
              coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_tripstages AS tt
          UNION DISTINCT
          SELECT
              -1,
              'Unknown',
              'Unknown',
              0,
              current_datetime(),
              current_datetime(),
              current_datetime()
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_TripStage';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      ## SELECT log_source, log_start_date, log_message,'I', -1, CAST(NULL as STRING);
      ## COLLECT STATISTICS is not supported in this dialect.
      ## COLLECT STATISTICS is not supported in this dialect.
      ## SET log_message = 'Created STATISTICS on dbo.Dim_TripStage_NEW';
      ## CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      ## CALL utility.tableswap('dbo.Dim_TripStage_NEW', 'dbo.Dim_TripStage');
      ## SET log_message = 'Completed dbo.Dim_TripStage table swap';
      ## CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));

      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      ## SELECT log_source, log_start_date, 'Completed full load' as log_message,'I', CAST(NULL as INT64), CAST(NULL as STRING);
      IF trace_flag = 1 THEN
        ## CALL EDW_TRIPS_SUPPORT.FromLog(log_source, substr(CAST(log_start_date as STRING), 1, 23));
        SELECT log_source,log_start_date;
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.TripStage' AS tablename,
            *
          FROM
            EDW_TRIPS.tripstage
        ORDER BY 2 DESC
        LIMIT 1000
        ;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        ## SELECT log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING);
        ## CALL EDW_TRIPS_SUPPORT.FromLog(log_source, substr(CAST(log_start_date as STRING), 1, 23));
        SELECT log_source,log_start_date;
        RAISE USING MESSAGE = error_message;
      END;
    END;
  /*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_TripStage_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%dbo.Dim_TripStage%' ORDER BY 1 DESC 
SELECT TOP 100 'dbo.Dim_TripStage' Table_Name, * FROM dbo.Dim_TripStage ORDER BY 2
--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================


*/
  END;