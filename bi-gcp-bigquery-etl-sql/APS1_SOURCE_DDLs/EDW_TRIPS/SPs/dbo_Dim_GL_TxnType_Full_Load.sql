CREATE PROC [dbo].[Dim_GL_TxnType_Full_Load] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_GL_TxnType table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	ARUN		2020-11-09	Created

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_GL_TxnType_Full_Load

EXEC Utility.FromLog 'dbo.Dim_GL_TxnType', 1
SELECT TOP 100 'dbo.Dim_GL_TxnType' Table_Name, * FROM dbo.Dim_GL_TxnType ORDER BY 2
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_GL_TxnType_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Dim_GL_TxnType
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_GL_TxnType_NEW') IS NOT NULL DROP TABLE dbo.Dim_GL_TxnType_NEW
		CREATE TABLE dbo.Dim_GL_TxnType_NEW WITH (CLUSTERED INDEX (TxnTypeID), DISTRIBUTION = REPLICATE) AS
		SELECT TxnTypeID,
			   TxnType,
			   TxnDesc,
			   TxnType_CategoryID,
			   StatementNote,
			   CustomerNote,
			   ViolatorNote,
			   IsAutomatic,
			   AdjustmentCategoryID,
			   LevelID,
			   [Status],
			   LevelCode,
			   BusinessUnitID,
			   CreatedDate,
			   CreatedUser,
			   UpdatedDate,
			   UpdatedUser,
			   SYSDATETIME() AS EDW_UpdateDate
		FROM LND_TBOS.Finance.TxnTypes
		OPTION (LABEL='dbo.Dim_GL_TxnType_NEW Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_GL_TxnType_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_01 ON dbo.Dim_GL_TxnType_NEW (TxnTypeID);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_02 ON dbo.Dim_GL_TxnType_NEW (TxnType);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_03 ON dbo.Dim_GL_TxnType_NEW (TxnDesc);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_04 ON dbo.Dim_GL_TxnType_NEW (TxnType_CategoryID);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_05 ON dbo.Dim_GL_TxnType_NEW (StatementNote);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_06 ON dbo.Dim_GL_TxnType_NEW (CustomerNote);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_07 ON dbo.Dim_GL_TxnType_NEW (ViolatorNote);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_08 ON dbo.Dim_GL_TxnType_NEW (IsAutomatic);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_09 ON dbo.Dim_GL_TxnType_NEW (LevelID);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_10 ON dbo.Dim_GL_TxnType_NEW ([Status]);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_11 ON dbo.Dim_GL_TxnType_NEW (LevelCode);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_12 ON dbo.Dim_GL_TxnType_NEW (BusinessUnitID);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_13 ON dbo.Dim_GL_TxnType_NEW (CreatedDate);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_14 ON dbo.Dim_GL_TxnType_NEW (CreatedUser);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_15 ON dbo.Dim_GL_TxnType_NEW (UpdatedDate);
		CREATE STATISTICS STATS_dbo_Dim_GL_TxnType_16 ON dbo.Dim_GL_TxnType_NEW (UpdatedUser);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_GL_TxnType_NEW', 'dbo.Dim_GL_TxnType'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Dim_GL_TxnType' TableName, * FROM dbo.Dim_GL_TxnType ORDER BY 2 DESC
	
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
EXEC dbo.Dim_GL_TxnType_Load

EXEC Utility.FromLog 'dbo.Dim_GL_TxnType', 1
SELECT TOP 100 'dbo.Dim_GL_TxnType' Table_Name, * FROM dbo.Dim_GL_TxnType ORDER BY 2


*/


