CREATE PROC [dbo].[Dim_AppTxnType_Full_Load] AS

/*
IF OBJECT_ID ('dbo.Dim_AppTxnType_Full_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Dim_AppTxnType_Full_Load
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_AppTxnType table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Gouthami		2020-10-13	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_AppTxnType_Full_Load 

EXEC Utility.FromLog 'dbo.Dim_AppTxnType', 1
SELECT 'LND_TBOS.MIR.ReasonCodes' Table_name,* FROM LND_TBOS.MIR.ReasonCodes ORDER BY 2
SELECT TOP 100 'dbo.Dim_AppTxnType' Table_Name, * FROM dbo.Dim_AppTxnType ORDER BY 2
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_AppTxnType_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Dim_AppTxnType
		--=============================================================================================================
		IF OBJECT_ID('dbo.Dim_AppTxnType_NEW') IS NOT NULL DROP TABLE dbo.Dim_AppTxnType_NEW
		CREATE TABLE dbo.Dim_AppTxnType_NEW WITH (CLUSTERED INDEX (AppTxnTypeID), DISTRIBUTION = REPLICATE) AS
		SELECT	TT.AppTxnTypeID,
				TT.AppTxnTypeCode,
				TT.AppTxnTypeDesc,
				CONVERT(VARCHAR(20),REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(NULLIF(EFFECTED_BALANCETYPE_POSITIVE,''),'AdmHeriFee','AdmHeriFee'),'AdvancePayment','AdvancePayment'),'ZipCash','ZipCash'),'EMIBal','EMIBal'),'VioBal','VioBal'),'CollBal','CollBal'),'TollBal','TollBal')) Effected_BalanceType_Positive,
				CONVERT(VARCHAR(20),REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(NULLIF(EFFECTED_BALANCETYPE_NEGATIVE,''),'AdmHeriFee','AdmHeriFee'),'AdvancePayment','AdvancePayment'),'ZipCash','ZipCash'),'EMIBal','EMIBal'),'VioBal','VioBal'),'CollBal','CollBal'),'TollBal','TollBal')) Effected_BalanceType_Negative,
				CONVERT(VARCHAR(20),REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(NULLIF(MAIN_BALANCE_TYPE,''),'AdmHeriFee','AdmHeriFee'),'AdvancePayment','AdvancePayment'),'ZipCash','ZipCash'),'EMIBal','EMIBal'),'VioBal','VioBal'),'CollBal','CollBal'),'TollBal','TollBal')) Main_Balance_Type,
				TC1.CategoryID AS TxnTypeCategoryID, 
				LEFT(TC1.CategoryName,1) + LOWER(SUBSTRING(TC1.CategoryName,2,50)) TxnTypeCategory,
				ISNULL(TC2.CategoryID,TC1.CategoryID) AS TxnTypeParentCategoryID,
				ISNULL(LEFT(TC2.CategoryName,1) + LOWER(SUBSTRING(TC2.CategoryName,2,50)),LEFT(TC1.CategoryName,1) + LOWER(SUBSTRING(TC1.CategoryName,2,50))) TxnTypeParentCategory,
				SYSDATETIME() EDW_UpdateDate

		FROM 
				LND_TBOS.TollPlus.AppTxnTypes AS TT
				JOIN LND_TBOS.TollPlus.TxnType_Categories AS TC1
					ON TT.TxnType_CategoryID = TC1.CategoryID
				LEFT JOIN LND_TBOS.TollPlus.TxnType_Categories AS TC2
					ON TC1.Parent_CategoryID = TC2.CategoryID
		UNION ALL 
		SELECT -1, 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', -1,  'Unknown', -1, 'Unknown', SYSDATETIME() AS EDW_UpdateDate
		OPTION (LABEL = 'dbo.Dim_AppTxnType_NEW_SET Load');
		
		SET  @Log_Message = 'Loaded dbo.Dim_AppTxnType_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_YOUR_SCHEMA_Dim_AppTxnType_01 ON dbo.Dim_AppTxnType_NEW (AppTxnTypeCode)
		CREATE STATISTICS STATS_YOUR_SCHEMA_Dim_AppTxnType_02 ON dbo.Dim_AppTxnType_NEW (TxnTypeCategoryID)
		CREATE STATISTICS STATS_YOUR_SCHEMA_Dim_AppTxnType_03 ON dbo.Dim_AppTxnType_NEW (TxnTypeParentCategoryID)
		
		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_AppTxnType_NEW', 'dbo.Dim_AppTxnType'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Dim_AppTxnType' TableName, * FROM dbo.Dim_AppTxnType ORDER BY 2 DESC
	
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
EXEC dbo.Dim_AppTxnType_Full_Load

EXEC Utility.FromLog 'dbo.Dim_AppTxnType', 1
SELECT 'LND_TBOS.MIR.ReasonCodes' Table_name,* FROM LND_TBOS.MIR.ReasonCodes ORDER BY 2
SELECT TOP 100 'dbo.Dim_AppTxnType' Table_Name, * FROM dbo.Dim_AppTxnType ORDER BY 2

*/


