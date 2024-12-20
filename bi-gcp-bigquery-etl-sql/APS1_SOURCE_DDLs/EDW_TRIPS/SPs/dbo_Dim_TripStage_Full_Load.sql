CREATE PROC [dbo].[Dim_TripStage_Full_Load] AS
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

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_TripStage_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Dim_TripStages
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_TripStage_NEW','U') IS NOT NULL    DROP TABLE dbo.Dim_TripStage_NEW;
		CREATE TABLE  dbo.Dim_TripStage_NEW WITH (CLUSTERED INDEX(TripStageID), DISTRIBUTION = REPLICATE)
		AS 
		SELECT  
				ISNULL(CAST(TT.TripStageID AS BIGINT), -1) AS TripStageID,
				ISNULL(CAST(TT.TripStageCode AS varchar(50)), '') AS TripStageCode,
			    ISNULL(CAST(TT.TripStageDescription AS varchar(250)), '') AS TripStageDesc,
                ISNULL(CAST(TT.ParentStageID AS BIGINT), -1) AS ParentStageID,
                ISNULL(CAST(TT.UpdatedDate AS DATETIME2(3)), '1900-01-01') AS UpdatedDate,
				ISNULL(CAST(TT.LND_UpdateDate AS datetime2(3)), '1900-01-01') AS LND_UpdateDate,
				ISNULL(CAST(SYSDATETIME() AS datetime2(3)), '1900-01-01') AS EDW_UpdateDate
	 	FROM LND_TBOS.TollPlus.TripStages TT
		UNION 
		SELECT -1, 'Unknown', 'Unknown', 0, SYSDATETIME(), SYSDATETIME(),SYSDATETIME() -- Added by Shekhar for Unknown TripStageCode on 7/21/2022

		SET  @Log_Message = 'Loaded dbo.Dim_TripStage_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_TripStage_01 ON dbo.Dim_TripStage_NEW (TripStageID);
		CREATE STATISTICS STATS_dbo_TripStage_02 ON dbo.Dim_TripStage_NEW (TripStageCode);
		CREATE STATISTICS STATS_dbo_TripStage_03 ON dbo.Dim_TripStage_NEW (TripStageDesc);
		CREATE STATISTICS STATS_dbo_TripStage_04 ON dbo.Dim_TripStage_NEW (ParentStageID);

		SET  @Log_Message = 'Created STATISTICS on dbo.Dim_TripStage_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_TripStage_NEW', 'dbo.Dim_TripStage'

		SET  @Log_Message = 'Completed dbo.Dim_TripStage table swap' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.TripStage' TableName, * FROM dbo.TripStage ORDER BY 2 DESC
	
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
EXEC dbo.Dim_TripStage_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%dbo.Dim_TripStage%' ORDER BY 1 DESC 
SELECT TOP 100 'dbo.Dim_TripStage' Table_Name, * FROM dbo.Dim_TripStage ORDER BY 2
--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================


*/


