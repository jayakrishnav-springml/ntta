CREATE PROC [dbo].[Dim_InvoiceStage_Full_Load] AS
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_InvoiceStage table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Ranjith Nair	2020-10-14	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_InvoiceStage_Full_Load

EXEC Utility.FromLog 'dbo.Dim_InvoiceStage', 1
SELECT TOP 100 'dbo.Dim_InvoiceStage' Table_Name, * FROM dbo.Dim_InvoiceStage ORDER BY 2
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_InvoiceStage_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Dim_InvoiceStage
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_InvoiceStage_NEW') IS NOT NULL DROP TABLE dbo.Dim_InvoiceStage_NEW
		CREATE TABLE dbo.Dim_InvoiceStage_NEW WITH (CLUSTERED INDEX (InvoiceStageID), DISTRIBUTION = REPLICATE) AS
		SELECT StageID AS InvoiceStageID,
			   StageCode AS InvoiceStageCode,
			   StageName AS InvoiceStageDesc,
			   AgingPeriod,
			   GracePeriod,
			   WaiveAllFees,
			   ApplyAVIRate,
			   StageOrder,
			   SYSDATETIME() AS EDW_UpdatedDate
		FROM LND_TBOS.TollPlus.Ref_Invoice_Workflow_Stages
		UNION ALL
		SELECT -1,
			   'Unknown',
			   'Unknown',
			   0,
			   0,
			   0,
			   0,
			   0,
			   SYSDATETIME() AS EDW_UpdatedDate
		OPTION (LABEL = 'dbo.Dim_InvoiceStage_NEW_SET Load');;
		
		SET  @Log_Message = 'Loaded dbo.Dim_InvoiceStage_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_YOUR_SCHEMA_Dim_InvoiceStage_01 ON dbo.Dim_InvoiceStage_NEW (InvoiceStageCode);
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_InvoiceStage_NEW', 'dbo.Dim_InvoiceStage'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Dim_InvoiceStage' TableName, * FROM dbo.Dim_InvoiceStage ORDER BY 2 DESC
	
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
EXEC dbo.Dim_InvoiceStage_Full_Load

EXEC Utility.FromLog 'dbo.Dim_InvoiceStage', 1
SELECT 'LND_TBOS.MIR.ReasonCodes' Table_name,* FROM LND_TBOS.MIR.ReasonCodes ORDER BY 2
SELECT TOP 100 'dbo.Dim_InvoiceStage' Table_Name, * FROM dbo.Dim_InvoiceStage ORDER BY 2

*/


