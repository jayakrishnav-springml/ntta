CREATE OR REPLACE PROCEDURE EDW_TRIPS.Fact_TollTransactionYearlySummary_Full_Load()
BEGIN

  /*
IF OBJECT_ID ('[dbo].[Fact_TollTransactionYearlySummary_Full_Load]', 'P') IS NOT NULL DROP PROCEDURE [dbo].[Fact_TollTransactionYearlySummary_Full_Load] 
###################################################################################################################
Proc Description: 
##################################################################################################################-
The marketing department has a need to analyze Toll Tag Accounts on a regular basis (weekly,monthly).
Multiple data files have been provided to Don to fulfill these requirements. The EDW team thinks that
these regular requirements can be fulfilled by providing a Microstrategy dossier. The summary table
loaded by this stored procedure will provide data to Micro Strategy dossier.


@IsFullLoad parameter is passed to this procedure. The value of this parameter dictates whether the fact
table is loaded fully or incrementally 
	@IsFullLoad = 1          means full load, 
	@IsFullLoad	= 0 or NULL  means incremental load.
	
Note: Incremantal load feature has not yet ben implemented even though the @IsFullLoad parameter is passed

===================================================================================================================
Change Log:
##################################################################################################################-
CHG0039993		Shekhar T.		11-18-2021		New!
CHG0040142      Sagarika Ch.    12-15-2021      Changed the join as previous join dbo.Dim_VehicleTag was causing duplicate
                                                counts and ignoring Date ranges.
===================================================================================================================
Example:
##################################################################################################################-
EXEC [dbo].[Fact_TollTransactionYearlySummary_Full_Load] 

###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_TollTransactionYearlySummary_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE load_begin_date DATETIME;
      DECLARE log_message STRING;
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      SET load_begin_date = DATE(datetime_sub(current_datetime(), interval 12 MONTH));
      --Testing : Static date to generate Output same as APS Last Run
      --SET load_begin_date = DATE(datetime_sub(Date('2024-02-04'), interval 12 MONTH));
      
      -- Insert a row into the Log table saying 'Started Full Load'
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));

		--=============================================================================================================
		-- Load [dbo].[Fact_TollTransactionYearlySummary]
		--=============================================================================================================
		

      -- DROP TABLE IF EXISTS EDW_TRIPS.Fact_TollTransactionYearlySummary_New;
      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_TollTransactionYearlySummary
      CLUSTER by customerid
        AS
          SELECT
              extract(YEAR from CAST(tripdate as DATE)) AS yearid,
              ct.customerid AS customerid,
              ct.vehicletagid AS vehicletagid,
              ct.custtagid,
              count(*) AS txncount,
              sum(ct.tollamount) AS tollsdue
            FROM
              LND_TBOS.TollPlus_TP_Trips AS tt
              INNER JOIN EDW_TRIPS.Fact_TollTransaction AS ct ON tt.tptripid = ct.tptripid
               AND tt.linkid = ct.custtripid
               AND tt.tripwith = 'C'
               AND ct.deleteflag = 0
            WHERE tripdate >= load_begin_date
            GROUP BY extract(YEAR from CAST(tripdate as DATE)), customerid, vehicletagid, custtagid
      ;
      -- Log
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Loaded EDW_TRIPS.Fact_TollTransactionYearlySummary_New', 'I', -1, CAST(NULL as STRING));
      
      -- Log.
      -- Table swap!
      -- CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Fact_TollTransactionYearlySummary_New', 'EDW_TRIPS.Fact_TollTransactionYearlySummary');
      --TableSwap is Not Required, using  Create or Replace Table

      -- Insert a row into the log table with the following message.
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      -- Show results
      IF trace_flag = 1 THEN
        -- CALL EDW_TRIPS_SUPPORT.FromLog(log_source, substr(CAST(log_start_date as STRING), 1, 23));
        SELECT log_source,log_start_date;
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_TollTransactionYearlySummary' AS tablename,
            *
          FROM
            EDW_TRIPS.Fact_TollTransactionYearlySummary
        ORDER BY 2 DESC
        LIMIT 1000
        ;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message; -- Rethrow the error!
      END;
    END;

    
--/*
----===============================================================================================================
---- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
----===============================================================================================================

--EXEC [dbo].[Fact_TollTransactionYearlySummary_Full_Load] 1   -- For Full Load
--EXEC Utility.FromLog '[dbo].[Fact_TollTransactionYearlySummary_Full_Load]', 1
--SELECT TOP 100 '[dbo].[Fact_TollTransactionYearlySummary]' Table_Name, * FROM [dbo].[Fact_TollTransactionYearlySummary] ORDER BY 2

----===============================================================================================================
---- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
----===============================================================================================================

	--DECLARE @Log_Message		VARCHAR(1000)
	--	DECLARE @Row_Count			BIGINT
	--	DECLARE @Partition_Ranges	VARCHAR(MAX)
	--	DECLARE @Log_Source			VARCHAR(100)	= 'dbo.Fact_TollTransactionYearlySummary_Full_Load'
	--	DECLARE @Log_Start_Date		DATETIME2 (3)	= GETDATE()
	--	DECLARE @Trace_Flag			BIT				= 1 -- This flag is set to 1 if trace level messages are needed. Usually for Testing. 
	--	DECLARE @LoadBeginDate		DATETIME		= '01-01-2021' -- The data in the summary table will be loaded from this date onward
	--	DECLARE @New_Table_Name		VARCHAR(100)	= 'dbo.Fact_TollTransactionYearlySummary_New' -- This table will be dropped and created
	--	DECLARE @Main_Table_Name	VARCHAR(100)	= 'dbo.Fact_TollTransactionYearlySummary' -- and then will be swapped with this table
	
	--SELECT * FROM Utility.ProcessLog ORDER BY  logdate desc


--*/



  END;