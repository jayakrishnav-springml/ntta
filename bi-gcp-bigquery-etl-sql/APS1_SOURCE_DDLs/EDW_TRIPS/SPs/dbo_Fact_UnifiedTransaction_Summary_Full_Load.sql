CREATE PROC [dbo].[Fact_UnifiedTransaction_Summary_Full_Load] AS
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_UnifiedTransaction_Summary table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040134	Shankar		2021-12-10	New!
CHG0040343	Shankar		2022-01-31	1. Get OOSPlateFlag for all transaction types, not just video.
									2. Add the First Payment Date and Last Payment Date columns. 
									3. Get Paid Amount for prepaid trips from TP_CustomerTrips along with Adj.
CHG0040744	Shankar		2022-04-13	Added AdjustedExpectedAmount and few new columns from dbo.Fact_UnifiedTransaction
CHG0041141	Shankar		2022-06-17	Added LaneTripIdentMethodID, RecordTypeID, Rpt_PaidvsAEA from dbo.Fact_UnifiedTransaction
CHG0041406  Shekhar		2022-08-23  Added the following two columns 
									1. VTollFlag - A flag to identify if a transaction is VTolled or not
									2. ClassAdjustmentFlag - A flag to identify if a transaction has any class adjustment
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_UnifiedTransaction_Summary_Full_Load
 
SELECT * FROM Utility.ProcessLog Where LogSource = 'dbo.Fact_UnifiedTransaction_Summary_Full_Load' ORDER BY 1 DESC
SELECT TOP 1000 'Stage.UnifiedTransaction' TableName, * FROM Stage.UnifiedTransaction ORDER BY TripDate DESC,TPTripID
SELECT TOP 1000 'dbo.Fact_UnifiedTransaction' TableName, * FROM dbo.Fact_UnifiedTransaction ORDER BY TripDate DESC,TPTripID
SELECT TOP 1000 'dbo.Fact_UnifiedTransaction_Summary' TableName, * FROM dbo.Fact_UnifiedTransaction_Summary ORDER BY 2 DESC,3,4
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_UnifiedTransaction_Summary_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started full load', 'I', NULL, NULL

		--=============================================================================================================
		-- dbo.Fact_UnifiedTransaction_Summary 
		--=============================================================================================================

		IF OBJECT_ID('dbo.Fact_UnifiedTransaction_Summary_NEW','U') IS NOT NULL DROP TABLE dbo.Fact_UnifiedTransaction_Summary_NEW
		CREATE TABLE dbo.Fact_UnifiedTransaction_Summary_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TripDayID)) AS
		SELECT 
			  TripDayID
			, LaneID
			, OperationsMappingID
			, TripWith
			, SourceofEntry
			, TripIdentMethodID
			, LaneTripIdentMethodID
			, RecordTypeID
			, TransactionPostingTypeID
			, TripStageID
			, TripStatusID
			, ReasonCodeID
			, CitationStageID
			, TripPaymentStatusID
			, VehicleClassID
			, BadAddressFlag
			, NonRevenueFlag
			, BusinessRuleMatchedFlag
			, ManuallyReviewedFlag
			, OOSPlateFlag
			, VTollFlag
			, ClassAdjustmentFlag
			, Rpt_PaidvsAEA
			, CAST(FirstPaidDate AS DATE)							AS FirstPaidDate
			, CAST(LastPaidDate  AS DATE)							AS LastPaidDate
			, COUNT_BIG(1)											AS TxnCount
			, CAST(SUM(ExpectedAmount)			AS DECIMAL(19,2))	AS ExpectedAmount
			, CAST(SUM(AdjustedExpectedAmount)	AS DECIMAL(19,2))	AS AdjustedExpectedAmount
			, CAST(SUM(CalcAdjustedAmount)		AS DECIMAL(19,2))	AS CalcAdjustedAmount
			, CAST(SUM(TripWithAdjustedAmount)	AS DECIMAL(19,2))	AS TripWithAdjustedAmount
			, CAST(SUM(TollAmount)				AS DECIMAL(19,2))	AS TollAmount
			, CAST(SUM(ActualPaidAmount)		AS DECIMAL(19,2))	AS ActualPaidAmount
			, CAST(SUM(OutstandingAmount)		AS DECIMAL(19,2))	AS OutstandingAmount
			, MAX(LND_UpdateDate)									AS LND_UpdateDate
			, CAST(SYSDATETIME() AS DATETIME2(3))					AS EDW_UpdateDate
		FROM 
			dbo.Fact_UnifiedTransaction
		GROUP BY 
			  TripDayID
			, LaneID
			, OperationsMappingID
			, TripWith
			, SourceofEntry
			, TripIdentMethodID
			, LaneTripIdentMethodID
			, RecordTypeID
			, TransactionPostingTypeID
			, TripStageID
			, TripStatusID
			, ReasonCodeID
			, CitationStageID
			, TripPaymentStatusID
			, VehicleClassID
			, BadAddressFlag
			, NonRevenueFlag
			, BusinessRuleMatchedFlag
			, ManuallyReviewedFlag
			, OOSPlateFlag
			, VTollFlag
			, ClassAdjustmentFlag
			, Rpt_PaidvsAEA
			, CAST(FirstPaidDate AS DATE)  
			, CAST(LastPaidDate AS DATE)  
		OPTION (LABEL = 'dbo.Fact_UnifiedTransaction_Summary_NEW Load');

		SET  @Log_Message = 'Loaded dbo.Fact_UnifiedTransaction_Summary_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Create Statistics
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_001 ON dbo.Fact_UnifiedTransaction_Summary_NEW(TripDayID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_002 ON dbo.Fact_UnifiedTransaction_Summary_NEW(LaneID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_003 ON dbo.Fact_UnifiedTransaction_Summary_NEW(OperationsMappingID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_004 ON dbo.Fact_UnifiedTransaction_Summary_NEW(TripWith)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_005 ON dbo.Fact_UnifiedTransaction_Summary_NEW(TripIdentMethodID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_006 ON dbo.Fact_UnifiedTransaction_Summary_NEW(TransactionPostingTypeID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_007 ON dbo.Fact_UnifiedTransaction_Summary_NEW(TripStageID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_008 ON dbo.Fact_UnifiedTransaction_Summary_NEW(TripStatusID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_009 ON dbo.Fact_UnifiedTransaction_Summary_NEW(ReasonCodeID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_010 ON dbo.Fact_UnifiedTransaction_Summary_NEW(CitationStageID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_011 ON dbo.Fact_UnifiedTransaction_Summary_NEW(TripPaymentStatusID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_012 ON dbo.Fact_UnifiedTransaction_Summary_NEW(VehicleClassID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_014 ON dbo.Fact_UnifiedTransaction_Summary_NEW(BadAddressFlag)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_015 ON dbo.Fact_UnifiedTransaction_Summary_NEW(NonRevenueFlag)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_016 ON dbo.Fact_UnifiedTransaction_Summary_NEW(BusinessRuleMatchedFlag)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_017 ON dbo.Fact_UnifiedTransaction_Summary_NEW(ManuallyReviewedFlag)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_018 ON dbo.Fact_UnifiedTransaction_Summary_NEW(OOSPlateFlag)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_019 ON dbo.Fact_UnifiedTransaction_Summary_NEW(FirstPaidDate)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_020 ON dbo.Fact_UnifiedTransaction_Summary_NEW(LastPaidDate)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_021 ON dbo.Fact_UnifiedTransaction_Summary_NEW(SourceofEntry)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_022 ON dbo.Fact_UnifiedTransaction_Summary_NEW(LaneTripIdentMethodID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_023 ON dbo.Fact_UnifiedTransaction_Summary_NEW(RecordTypeID)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_024 ON dbo.Fact_UnifiedTransaction_Summary_NEW(VTollFlag)
		CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_025 ON dbo.Fact_UnifiedTransaction_Summary_NEW(ClassAdjustmentFlag)
		


		SET  @Log_Message = 'Created STATISTICS on dbo.Fact_UnifiedTransaction_Summary_NEW' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		-- Table swap!
		EXEC Utility.TableSwap 'dbo.Fact_UnifiedTransaction_Summary_NEW', 'dbo.Fact_UnifiedTransaction_Summary'

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Fact_UnifiedTransaction_Summary' TableName, * FROM dbo.Fact_UnifiedTransaction_Summary ORDER BY 2 DESC
	
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
EXEC dbo.Fact_UnifiedTransaction_Summary_Full_Load
SELECT * FROM Utility.ProcessLog Where LogSource = 'dbo.Fact_UnifiedTransaction_Summary_Full_Load' ORDER BY 1 DESC
SELECT TOP 100 'dbo.Fact_UnifiedTransaction' Table_Name, * FROM dbo.Fact_UnifiedTransaction ORDER BY 2
SELECT TOP 100 'dbo.Fact_UnifiedTransaction_Summary' Table_Name, * FROM dbo.Fact_UnifiedTransaction_Summary ORDER BY 2

*/
 
