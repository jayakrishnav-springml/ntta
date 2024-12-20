CREATE PROC [dbo].[Dim_TripStatus_Full_Load] AS


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

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_TripStatus_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Dim_TripStatus
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_TripStatus_NEW','U') IS NOT NULL    DROP TABLE dbo.Dim_TripStatus_NEW;
		CREATE TABLE  dbo.Dim_TripStatus_NEW WITH (CLUSTERED INDEX(TripStatusID), DISTRIBUTION = REPLICATE)
		AS 
		SELECT  
				ISNULL(CAST(TS.TripStatusID AS BIGINT), -1) AS TripStatusID,
				ISNULL(CAST(TS.TripStatusCode AS varchar(50)), '') AS TripStatusCode,
			    ISNULL(CAST(TS.TripStatusDescription AS varchar(250)), '') AS TripStatusDesc,
				ISNULL(CAST(TS.LND_UpdateDate AS datetime2(3)), '1900-01-01') AS LND_UpdateDate,
				ISNULL(CAST(SYSDATETIME() AS datetime2(3)), '1900-01-01') AS EDW_UpdateDate
          	FROM LND_TBOS.TollPlus.TripStatuses TS
		UNION
		SELECT	-1, 'Unknown', 'Unknown', SYSDATETIME(),SYSDATETIME()
			
		SET  @Log_Message = 'Loaded dbo.TripStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_TripStatus_01 ON dbo.Dim_TripStatus_NEW (TripStatusID);
		CREATE STATISTICS STATS_dbo_TripStatus_02 ON dbo.Dim_TripStatus_NEW (TripStatusCode);
		CREATE STATISTICS STATS_dbo_TripStatus_03 ON dbo.Dim_TripStatus_NEW (TripStatusDesc);

		SET  @Log_Message = 'Created STATISTICS on dbo.Dim_TripStatus_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_TripStatus_NEW', 'dbo.Dim_TripStatus'

		SET  @Log_Message = 'Completed dbo.Dim_TripStatus table swap' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Dim_TripStatus' TableName, * FROM dbo.Dim_TripStatus ORDER BY 2 DESC
	
	END	TRY
	
	BEGIN CATCH
		
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH

END

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


