CREATE PROC [dbo].[Dim_CitationStage_Full_Load] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_CitationStage table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Gouthami		2020-10-14	New!
CHG0040134	Shankar			2021-12-15	Misc. Reporting cosmetics.
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_CitationStage_Full_Load

EXEC Utility.FromLog 'dbo.Dim_CitationStage', 1
SELECT 'LND_TBOS.MIR.TransactionTypes' Table_name,* FROM LND_TBOS.MIR.TransactionTypes ORDER BY 2
SELECT TOP 100 'dbo.Dim_CitationStage' Table_Name, * FROM dbo.Dim_CitationStage ORDER BY 2
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_CitationStage_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Dim_CitationStage
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_CitationStage_NEW') IS NOT NULL DROP TABLE dbo.Dim_CitationStage_NEW
		CREATE TABLE dbo.Dim_CitationStage_NEW WITH (CLUSTERED INDEX (CitationStageID), DISTRIBUTION = REPLICATE) AS
		SELECT StageID AS CitationStageID, StageCode AS CitationStageCode, StageName AS CitationStageDesc,	
			AgingPeriod, GracePeriod, WaiveAllFees, ApplyAVIRate,StageOrder, SYSDATETIME() AS EDW_UpdateDate
		 FROM   LND_TBOS.TOLLPLUS.REF_INVOICE_WORKFLOW_STAGES 
			UNION ALL 
			SELECT -1, 'Unknown', 'Unknown', 0,0,0,0,-1, SYSDATETIME() AS EDW_UpdateDate
			UNION ALL
			SELECT 0,'INVOICE','Invoice',0,0,0,0,0, SYSDATETIME() AS EDW_UpdateDate
			OPTION (LABEL = 'dbo.Dim_CitationStage_NEW Load');
		SET  @Log_Message = 'Loaded dbo.Dim_CitationStage_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_CitationStage_01 ON dbo.Dim_CitationStage_NEW (CitationStageCode);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_CitationStage_NEW', 'dbo.Dim_CitationStage'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Dim_CitationStage' TableName, * FROM dbo.Dim_CitationStage ORDER BY 2 DESC
	
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
EXEC dbo.Dim_CitationStage_Full_Load

EXEC Utility.FromLog 'dbo.Dim_CitationStage', 1
SELECT 'LND_TBOS.MIR.TransactionTypes' Table_name,* FROM LND_TBOS.MIR.TransactionTypes ORDER BY 2
SELECT TOP 100 'dbo.Dim_CitationStage' Table_Name, * FROM dbo.Dim_CitationStage ORDER BY 2

*/


