CREATE PROC [dbo].[Fact_TollTransactionYearlySummary_Full_Load] AS
/*
IF OBJECT_ID ('[dbo].[Fact_TollTransactionYearlySummary_Full_Load]', 'P') IS NOT NULL DROP PROCEDURE [dbo].[Fact_TollTransactionYearlySummary_Full_Load] 
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------------------------------------------
CHG0039993		Shekhar T.		11-18-2021		New!
CHG0040142      Sagarika Ch.    12-15-2021      Changed the join as previous join dbo.Dim_VehicleTag was causing duplicate
                                                counts and ignoring Date ranges.
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC [dbo].[Fact_TollTransactionYearlySummary_Full_Load] 

###################################################################################################################
*/

	BEGIN
	 BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_TollTransactionYearlySummary_Full_Load',@Log_Start_Date DATETIME2(3) = SYSDATETIME();
		DECLARE @Log_Message VARCHAR(1000),@Row_Count BIGINT,@Trace_Flag BIT = 0; -- Testing
		DECLARE @Load_Begin_date DATETIME2(3)= CAST(DATEADD(Month, -12, GETDATE()) AS DATE);

		-- Insert a row into the Log table saying 'Started Full Load'
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL;

		--=============================================================================================================
		-- Load [dbo].[Fact_TollTransactionYearlySummary]
		--=============================================================================================================
		
		IF OBJECT_ID('dbo.Fact_TollTransactionYearlySummary_New') IS NOT NULL DROP TABLE dbo.Fact_TollTransactionYearlySummary_New
		CREATE TABLE dbo.Fact_TollTransactionYearlySummary_New WITH (CLUSTERED INDEX ( CustomerID ASC ), DISTRIBUTION = HASH(CustomerID)) 
		AS

		SELECT 		YEAR(TripDate)	AS 	YearID,
					ct.CustomerID												AS 	CustomerID,
					ct.VehicleTagID											AS 	VehicleTagID,
					ct.CustTagID,
					COUNT(*)													AS 	TxnCount, 
					SUM (ct.TollAmount)											AS 	TollsDue
		FROM 		LND_TBOS.tollplus.TP_Trips tt 
					JOIN  dbo.Fact_TollTransaction ct
						ON  tt.TpTripID			= ct.TpTripID
						AND tt.LinkID			= ct.CustTripID
						AND tt.TripWith			= 'C'
						AND ct.DeleteFlag = 0
		WHERE 		TripDate >= @Load_Begin_date
		GROUP  BY  YEAR(TripDate),
					ct.CustomerId,
					ct.VehicleTagID,
					ct.CustTagID
		OPTION (LABEL = 'dbo.Fact_TollTransactionYearlySummary_New');

		-- Log
		EXEC Utility.ToLog @Log_Source,@Log_Start_Date, 'Loaded dbo.Fact_TollTransactionYearlySummary_New','I',-1,NULL;

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Fact_TollTransactionYearlySummary_01 ON dbo.Fact_TollTransactionYearlySummary_New (YearID);
		CREATE STATISTICS STATS_dbo_Fact_TollTransactionYearlySummary_02 ON dbo.Fact_TollTransactionYearlySummary_New (CustomerID);
		CREATE STATISTICS STATS_dbo_Fact_TollTransactionYearlySummary_03 ON dbo.Fact_TollTransactionYearlySummary_New (VehicleTagID);
		CREATE STATISTICS STATS_dbo_Fact_TollTransactionYearlySummary_04 ON dbo.Fact_TollTransactionYearlySummary_New (CustTagID);
			
			-- Log.
		EXEC Utility.ToLog @Log_Source,@Log_Start_Date,'Statistics Created','I',NULL,NULL;


		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Fact_TollTransactionYearlySummary_New', 'dbo.Fact_TollTransactionYearlySummary';


		-- Insert a row into the log table with the following message.
		EXEC Utility.ToLog @Log_Source,@Log_Start_Date,'Completed full load','I',NULL,NULL;

		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date;
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Fact_TollTransactionYearlySummary' TableName,*	FROM dbo.Fact_TollTransactionYearlySummary	ORDER BY 2 DESC;
	
	END	TRY
	
	BEGIN CATCH
		
				DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
				EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
				EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
				THROW;  -- Rethrow the error!
	
	END CATCH;
		
END


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


