CREATE PROC [dbo].[Dim_ChartOfAccounts_Full_Load] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_ChartOfAccounts table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	ARUN		2020-11-09	Created

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_ChartOfAccounts_Full_Load

EXEC Utility.FromLog 'dbo.Dim_ChartOfAccounts', 1
SELECT TOP 100 'dbo.Dim_ChartOfAccounts' Table_Name, * FROM dbo.Dim_ChartOfAccounts ORDER BY 2
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Dim_ChartOfAccounts_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- Load dbo.Dim_ChartOfAccounts
		--=============================================================================================================
		 IF OBJECT_ID('dbo.Dim_ChartOfAccounts_NEW') IS NOT NULL DROP TABLE dbo.Dim_ChartOfAccounts_NEW
		 CREATE TABLE dbo.Dim_ChartOfAccounts_NEW WITH (CLUSTERED INDEX (ChartOfAccountID), DISTRIBUTION = REPLICATE) AS
		 SELECT Surrogate_COAID,
		 	    ChartOfAccountID,
		 	    AccountName,
		 	    ParentChartOfAccountID,
		 	    AgCode,
		 	    AsgCode,
		 	    LowerBound,
		 	    UpperBound,
		 	    [Status],
		 	    IsControlAccount,
		 	    NormalBalanceType,
		 	    LegalAccountID,
		 	    AgencyCode,
		 	    StartEffectiveDate,
		 	    EndEffectiveDate,
		 	    Comments,
		 	    IsDeleted,
		 	    CreatedDate,
		 	    CreatedUser,
		 	    UpdatedDate,
		 	    UpdatedUser,
		 	    SYSDATETIME() AS EDW_UpdateDate
		 FROM LND_TBOS.Finance.ChartOfAccounts
		 OPTION (LABEL = 'dbo.Dim_ChartOfAccounts_NEW Load');;
		
		SET  @Log_Message = 'Loaded dbo.Dim_ChartOfAccounts_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Create statistics
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_01 ON dbo.Dim_ChartOfAccounts_NEW (Surrogate_COAID);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_02 ON dbo.Dim_ChartOfAccounts_NEW (ChartOfAccountID);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_03 ON dbo.Dim_ChartOfAccounts_NEW (AccountName);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_04 ON dbo.Dim_ChartOfAccounts_NEW (ParentChartOfAccountID);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_05 ON dbo.Dim_ChartOfAccounts_NEW (AgCode);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_06 ON dbo.Dim_ChartOfAccounts_NEW (AsgCode);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_07 ON dbo.Dim_ChartOfAccounts_NEW (LowerBound);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_08 ON dbo.Dim_ChartOfAccounts_NEW (UpperBound);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_09 ON dbo.Dim_ChartOfAccounts_NEW ([Status]);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_10 ON dbo.Dim_ChartOfAccounts_NEW (IsControlAccount);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_11 ON dbo.Dim_ChartOfAccounts_NEW (NormalBalanceType);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_12 ON dbo.Dim_ChartOfAccounts_NEW (LegalAccountID);
        CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_13 ON dbo.Dim_ChartOfAccounts_NEW (CreatedDate);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_14 ON dbo.Dim_ChartOfAccounts_NEW (CreatedUser);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_15 ON dbo.Dim_ChartOfAccounts_NEW (UpdatedDate);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_16 ON dbo.Dim_ChartOfAccounts_NEW (UpdatedUser);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_17 ON dbo.Dim_ChartOfAccounts_NEW (AgencyCode);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_18 ON dbo.Dim_ChartOfAccounts_NEW (StartEffectiveDate);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_19 ON dbo.Dim_ChartOfAccounts_NEW (EndEffectiveDate);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_20 ON dbo.Dim_ChartOfAccounts_NEW (Comments);
		CREATE STATISTICS STATS_dbo_Dim_ChartOfAccounts_21 ON dbo.Dim_ChartOfAccounts_NEW (IsDeleted);

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Dim_ChartOfAccounts_NEW', 'dbo.Dim_ChartOfAccounts'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Dim_ChartOfAccounts' TableName, * FROM dbo.Dim_ChartOfAccounts ORDER BY 2 DESC
	
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
EXEC dbo.Dim_ChartOfAccounts_Load

EXEC Utility.FromLog 'dbo.Dim_ChartOfAccounts', 1
SELECT TOP 100 'dbo.Dim_ChartOfAccounts' Table_Name, * FROM dbo.Dim_ChartOfAccounts ORDER BY 2


*/


