CREATE PROC [dbo].[Dim_BusinessProcesses_Full_Load] AS

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

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_BusinessProcesses_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Dim_BusinessProcesses
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_BusinessProcesses_NEW') IS NOT NULL DROP TABLE dbo.Dim_BusinessProcesses_NEW
		CREATE TABLE dbo.Dim_BusinessProcesses_NEW WITH (CLUSTERED INDEX (BusinessProcessID), DISTRIBUTION = REPLICATE) AS
		SELECT BusinessProcessID,
			   BusinessProcessCode,
			   BusinessProcessDescription,
			   [Status],
			   IsAvailable,
			   SYSDATETIME() AS EDW_UpdateDate
		FROM LND_TBOS.Finance.BusinessProcesses
		OPTION (LABEL='dbo.Dim_BusinessProcesses_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_BusinessProcesses_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_BusinessProcesses_01 ON dbo.Dim_BusinessProcesses_NEW (BusinessProcessID);
		CREATE STATISTICS STATS_dbo_Dim_BusinessProcesses_02 ON dbo.Dim_BusinessProcesses_NEW (BusinessProcessCode);
		CREATE STATISTICS STATS_dbo_Dim_BusinessProcesses_03 ON dbo.Dim_BusinessProcesses_NEW (BusinessProcessDescription);
		CREATE STATISTICS STATS_dbo_Dim_BusinessProcesses_04 ON dbo.Dim_BusinessProcesses_NEW ([Status]);
		CREATE STATISTICS STATS_dbo_Dim_BusinessProcesses_05 ON dbo.Dim_BusinessProcesses_NEW (IsAvailable);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_BusinessProcesses_NEW', 'dbo.Dim_BusinessProcesses'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Dim_BusinessProcesses' TableName, * FROM dbo.Dim_BusinessProcesses ORDER BY 2 DESC
	
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
EXEC dbo.Dim_BusinessProcesses_Load

EXEC Utility.FromLog 'dbo.Dim_BusinessProcesses', 1
SELECT TOP 100 'dbo.Dim_BusinessProcesses' Table_Name, * FROM dbo.Dim_BusinessProcesses ORDER BY 2


*/


