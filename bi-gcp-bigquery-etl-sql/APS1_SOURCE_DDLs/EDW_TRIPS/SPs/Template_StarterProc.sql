CREATE PROC [Template].[StarterProc] AS

/*
IF OBJECT_ID ('YOUR_SCHEMA.YOUR_TABLE_Load', 'P') IS NOT NULL DROP PROCEDURE YOUR_SCHEMA.YOUR_TABLE_Load
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load YOUR_SCHEMA.YOUR_TABLE table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0000000	YOUR FIRST NAME		YYYY-MM-DD	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC YOUR_SCHEMA.YOUR_TABLE_Load

EXEC Utility.FromLog 'YOUR_SCHEMA.YOUR_TABLE', 1
SELECT TOP 100 'YOUR_SCHEMA.YOUR_TABLE' Table_Name, * FROM YOUR_SCHEMA.YOUR_TABLE ORDER BY 2
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'YOUR_SCHEMA.YOUR_TABLE_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 1 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load YOUR_SCHEMA.YOUR_TABLE
		--=============================================================================================================
		-- IF OBJECT_ID('YOUR_SCHEMA.YOUR_TABLE_NEW') IS NOT NULL DROP TABLE YOUR_SCHEMA.YOUR_TABLE_NEW
		-- CREATE TABLE YOUR_SCHEMA.YOUR_TABLE_NEW WITH (CLUSTERED INDEX (XXXX), DISTRIBUTION = XXXX) AS
		-- <<< YOUR TABLE LOAD SCRIPT >>>
		-- OPTION (LABEL = 'YOUR_SCHEMA.YOUR_TABLE_NEW Load');
		
		SET  @Log_Message = 'Loaded YOUR_TABLE_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		-- <<< YOUR CREATE STATISTICS SCRIPT >>> CREATE STATISTICS STATS_YOUR_SCHEMA_YOUR_TABLE_01 ON YOUR_TABLE_NEW (XXXX);
		
		-- Table swap!
		EXEC Utility.TableSwap 'YOUR_TABLE_NEW', 'YOUR_TABLE'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'YOUR_SCHEMA.YOUR_TABLE' TableName, * FROM YOUR_SCHEMA.YOUR_TABLE ORDER BY 2 DESC
	
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
EXEC YOUR_SCHEMA.YOUR_TABLE_Load

EXEC Utility.FromLog 'YOUR_SCHEMA.YOUR_TABLE', 1
SELECT TOP 100 'YOUR_SCHEMA.YOUR_TABLE' Table_Name, * FROM YOUR_SCHEMA.YOUR_TABLE ORDER BY 2

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================


*/


