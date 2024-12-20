CREATE PROC [dbo].[Dim_Channel_Full_Load] AS

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

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_Channel_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Dim_Channel
		--=============================================================================================================
		 IF OBJECT_ID('dbo.Dim_Channel_NEW') IS NOT NULL DROP TABLE dbo.Dim_Channel_NEW
		 CREATE TABLE dbo.Dim_Channel_NEW WITH (CLUSTERED INDEX (ChannelID), DISTRIBUTION = REPLICATE) AS
		 SELECT	ChannelID AS ChannelID, 
		 		ChannelName AS ChannelName, 
		 		ChannelDesc AS ChannelDesc,
		 		IsActive, 
				IsDisplay,
				SYSDATETIME() EDW_UpdateDate
		 FROM	LND_TBOS.TOLLPLUS.Channels
		 UNION ALL 
		 SELECT -1, 'Unknown', 'Unknown', 0, 0, SYSDATETIME() 
		 OPTION (LABEL = 'dbo.Dim_Channel_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_Channel_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_Channel_01 ON dbo.Dim_Channel_NEW (ChannelName);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_Channel_NEW', 'dbo.Dim_Channel'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Dim_Channel' TableName, * FROM dbo.Dim_Channel ORDER BY 2 DESC
	
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
EXEC dbo.Dim_Channel_Load

EXEC Utility.FromLog 'dbo.Dim_Channel', 1
SELECT TOP 100 'dbo.Dim_Channel' Table_Name, * FROM dbo.Dim_Channel ORDER BY 2

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================


*/


