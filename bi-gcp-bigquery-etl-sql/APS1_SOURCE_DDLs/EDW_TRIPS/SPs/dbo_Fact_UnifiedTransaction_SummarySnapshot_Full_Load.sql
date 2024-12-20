CREATE PROC [dbo].[Fact_UnifiedTransaction_SummarySnapshot_Full_Load] @BoardReportingRunFlag [BIT],@CreateSnapshotOnDemandFlag [BIT] AS 

/*
###########################################d########################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_UnifiedTransaction_SummarySnapshot table. This monthly snapshot table feeds Board Reporting.
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040134	Shankar		2021-12-10	New!
CHG0040343	Shankar		2022-01-31	1. Get OOSPlateFlag for all transaction types, not just video.
									2. Add the First Payment Month and Last Payment Month columns. 
									3. Get Paid Amount for prepaid trips from TP_CustomerTrips along with Adj.
CHG0040744	Shankar		2022-04-13	Added AdjustedExpectedAmount and few new columns from dbo.Fact_UnifiedTransaction
CHG0041141	Shankar		2022-06-30	Added Rpt_PaidvsAEA, Rpt_LPState, Rpt_InvUnInv, Rpt_VToll
CHG0041406  Shekhar     2022-08-23  Added VTollFlag & ClassAdjustmentFlag. No additional logic needed in the SP, as
                                    they are directled fetched from the Fact_Unified_Summary table.
CHG0042057  Shankar     2022-09-23  1. Embed three mapping output columns in Snapshot fact table to preserve this data in each snapshot
									2. Added AsOfDate to allow for multiple snapshots during one month. Data time period remains same.
									3. Multi-purpose proc interface.
									   @BoardReportingRunFlag		: Board Reporting OVERRIDE run to replace all the previous snapshot runs in the month. Start fresh.
									   @CreateSnapshotOnDemandFlag	: Create additional snapshots when needed ONLY AFTER the Board Reporting run is done including refreshing Unknown Mappings update.
									   
									   Scenario 1. Regular prod run, including the first run after 4th for Board Reporting Snapshot 
													@BoardReportingRunFlag = 0 /*auto-detect*/, @CreateSnapshotOnDemandFlag = 0 
									   Scenario 2. Refresh updated Unknown mappings in the latest Board Reporting Snapshot after confirming Pat updated all Unknown Operations mappings
													@BoardReportingRunFlag = 0 /*auto-detect*/, @CreateSnapshotOnDemandFlag = 0
									   Scenario 3. Board Reporting Snapshot already created. Subsequent runs during the month with this input do nothing.
													@BoardReportingRunFlag = 0, @CreateSnapshotOnDemandFlag = 0
									   Scenario 4. Override Board Reporting Snapshot to replace existing Board Reporting Snapshot with a new Snapshot 
													@BoardReportingRunFlag = 1 /*explicit instruction*/, @CreateSnapshotOnDemandFlag = 0 
									   Scenario 5. Create additional Snapshot(s) as and when needed after the first run which always reserved for Board Reporting Snapshot
													@BoardReportingRunFlag = 0, @CreateSnapshotOnDemandFlag = 1 /*explicit instruction*/ 
CHG0042378  Shankar     2023-01-31  Avoid unnecessary backup of 3 large tables when Pat completes unknown mappings update to save time.
									   
CHG0042058 Shankar		2024-01-09  1. Deleted new Unknown mapping rows in dbo.Dim_OperationsMapping which do not map to any Txns in the entire Bubble Snapshot fact table
									2. Updated table partition values on backup tables to include current year.  

*******************************************************************************************************************
    ATTENTION!  ==> Prod move peer review check. Keep @Trace_Flag BIT = 0, @Backup_Flag BIT = 0  <== ATTENTION!
*******************************************************************************************************************
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_UnifiedTransaction_SummarySnapshot_Full_Load @BoardReportingRunFlag = 0, @CreateSnapshotOnDemandFlag = 0
SELECT * FROM Utility.ProcessLog Where LogSource = 'dbo.Fact_UnifiedTransaction_SummarySnapshot_Full_Load' ORDER BY 1 DESC

SELECT TOP 1000 'dbo.Fact_UnifiedTransaction_Summary' TableName, * FROM dbo.Fact_UnifiedTransaction_Summary ORDER BY 2 DESC,3,4
SELECT TOP 1000 'dbo.Fact_UnifiedTransaction_SummarySnapshot' TableName, * FROM dbo.Fact_UnifiedTransaction_SummarySnapshot 
WHERE SnapshotMonthId = 202211 and TripIdentMethodID <> -1
ORDER BY 2 DESC, 3 DESC, 4,5,6,7
###################################################################################################################
*/

BEGIN

	BEGIN TRY
		
		--::>> DEBUG BLOCK BEGIN ===================================================================================
		
		--Uncomment for controlled test
		--DECLARE @BoardReportingRunFlag BIT = 0, @CreateSnapshotOnDemandFlag BIT = 1
		
		--Comment for controlled test
		DECLARE @Now DATETIME2(3) = SYSDATETIME(), @BoardReportingRunStartDay SMALLINT = 4 -- * I M P O R T A N T * --
		DECLARE @SnapshotMonthID INT = CAST(CONVERT(VARCHAR(6),CONVERT(DATETIME2(3),DATEADD(MS,-2,CONVERT(DATETIME,DATEADD(DAY,1,EOMONTH(SYSDATETIME(),-1))))),112) AS INT)
		DECLARE @MonthBeginDayID INT = CONVERT(VARCHAR,DATEADD(MONTH, DATEDIFF(MONTH, 0, SYSDATETIME()), 0),112)
		--Comment for controlled test		

		--Uncomment for controlled test run > Start
		--DECLARE @SnapshotMonthID INT = 202211, @MonthBeginDayID INT = 20221201, @Now DATETIME2(3) = '12/04/2022'
		--DECLARE @BoardReportingRunStartDay SMALLINT = 1
		--Uncomment for controlled test run > End

		--::>> DEBUG BLOCK END  ===================================================================================

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_UnifiedTransaction_SummarySnapshot_Full_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 /*Testing = 1. Prod = 0*/, @Backup_Flag BIT = 0 /*Testing = 1 or 0. Prod = 0*/ -- * I M P O R T A N T * --
		DECLARE @RefreshUnknownMappingsFlag BIT = 0, @UpdatedUnknownMappingsCount INT, @UnknownMappingsCount INT
		SELECT @BoardReportingRunFlag = ISNULL(@BoardReportingRunFlag,0), @CreateSnapshotOnDemandFlag = ISNULL(@CreateSnapshotOnDemandFlag,0)

		SELECT @Log_Message = 'Started Bubble Snapshot load for ' + CONVERT(VARCHAR,@SnapshotMonthID) + '. @BoardReportingRunFlag = ' + ISNULL(CONVERT(VARCHAR,@BoardReportingRunFlag),0) + ', @CreateSnapshotOnDemandFlag = ' + ISNULL(CONVERT(VARCHAR,@CreateSnapshotOnDemandFlag),0) 
		EXEC   Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		--:: Are there any Bubble Snapshots already present for @SnapshotMonthID?
		DECLARE @SnapshotMonthID_LastRun INT, @CurrentSnapshotsCount INT = 0, @EDW_UpdateDate_PrevRunThisMonth DATETIME2(3), @EDW_UpdateDate_ThisRun DATETIME2(3)
		DECLARE @AsOfDayID_LastRun INT, @AsOfDayID_BoardReportingRun INT

		SELECT	@SnapshotMonthID_LastRun = MAX(SnapshotMonthID), @AsOfDayID_LastRun = MAX(AsOfDayID)
		FROM	dbo.Fact_UnifiedTransaction_SummarySnapshot -- All Snapshots

		SELECT	@CurrentSnapshotsCount = COUNT(DISTINCT AsOfDayID), @AsOfDayID_BoardReportingRun = MIN(AsOfDayID), @EDW_UpdateDate_PrevRunThisMonth = MAX(EDW_UpdateDate)
		FROM	dbo.Fact_UnifiedTransaction_SummarySnapshot 
		WHERE	SnapshotMonthID = @SnapshotMonthID -- This month

		SELECT	@EDW_UpdateDate_ThisRun = MAX(EDW_UpdateDate)
		FROM	dbo.Fact_UnifiedTransaction_Summary 

		IF @Trace_Flag = 1
		SELECT @SnapshotMonthID [@SnapshotMonthID], @MonthBeginDayID [@MonthBeginDayID], @SnapshotMonthID_LastRun [@SnapshotMonthID_LastRun],  @AsOfDayID_LastRun [@AsOfDayID_LastRun], @AsOfDayID_BoardReportingRun [@AsOfDayID_BoardReportingRun], @EDW_UpdateDate_PrevRunThisMonth [@EDW_UpdateDate_PrevRunThisMonth], @EDW_UpdateDate_ThisRun [@EDW_UpdateDate_ThisRun], @CurrentSnapshotsCount [@CurrentSnapshotsCount], @BoardReportingRunFlag [@BoardReportingRunFlag], @CreateSnapshotOnDemandFlag [@CreateSnapshotOnDemandFlag]
		
		--:: Parameter conflict screening
		IF @BoardReportingRunFlag = 1 AND @CreateSnapshotOnDemandFlag = 1
		BEGIN
			SELECT @BoardReportingRunFlag = 0, @CreateSnapshotOnDemandFlag = 0 -- Reset them to normal run
			SELECT @Log_Message = 'If you need @CreateSnapshotOnDemandFlag = 1, pass @BoardReportingRunFlag as 0 as only one of them can be 1, not both. Ignore this invalid input and proceed with default run values @BoardReportingRunFlag = 0, @CreateSnapshotOnDemandFlag = 0'
			EXEC   Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
		END
        
		--:: Wait until 4th of the month for the first Bubble Snapshot run of the month
		IF  DATEPART(DAY,@Now) < @BoardReportingRunStartDay AND @Trace_Flag = 0
		BEGIN
			SELECT @BoardReportingRunFlag = 0, @CreateSnapshotOnDemandFlag = 0 -- Automatically turn it off!
			SELECT @Log_Message = 'Wait until 4th of the month for the first Bubble Snapshot run of the month for ' + CONVERT(VARCHAR,@SnapshotMonthID) + '. Take it easy!'
			EXEC   Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
		END
		
		--:: First Snapshot of the month is always used for Board Reporting. Subsequent snapshots can be created on demand based on special needs. 
		IF  DATEPART(DAY,@Now) >= @BoardReportingRunStartDay
			AND @CurrentSnapshotsCount = 0
		BEGIN
			SELECT @BoardReportingRunFlag = 1 /* Automatically turn it on! */,  @CreateSnapshotOnDemandFlag = 0 /*Automatically turn it off!*/
			SELECT @Log_Message = 'Detected the first run after 4th of the month for Board Reporting Snapshot ' + CONVERT(VARCHAR,@SnapshotMonthID) + '! Turned on @BoardReportingRunFlag = ' + ISNULL(CONVERT(VARCHAR,@BoardReportingRunFlag),0) 
			EXEC   Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
		END
		
		--:: Refresh Unknown mapping data in fact table? Auto detect if Pat completed Unknown Mappings update after the last Bubble Snapshot run.  
		SELECT	@UpdatedUnknownMappingsCount = COUNT(DISTINCT SS.OperationsMappingID) 
		FROM	dbo.Fact_UnifiedTransaction_SummarySnapshot SS 
				JOIN dbo.Dim_OperationsMapping OM 
					ON OM.OperationsMappingID = SS.OperationsMappingID 
		WHERE	SS.SnapshotMonthID = @SnapshotMonthID 
				AND SS.AsOfDayID = @AsOfDayID_LastRun
				AND (SS.MappingDetailed = 'Unknown' OR SS.PursUnpursStatus = 'Unknown') -- not in fact table
				AND (OM.MappingDetailed <> 'Unknown' AND OM.PursUnpursStatus <> 'Unknown') -- in dim table

		SELECT	@UnknownMappingsCount = COUNT(DISTINCT SS.OperationsMappingID) 
		FROM	dbo.Fact_UnifiedTransaction_SummarySnapshot SS 
				JOIN dbo.Dim_OperationsMapping OM 
					ON OM.OperationsMappingID = SS.OperationsMappingID  
		WHERE	SS.SnapshotMonthID = @SnapshotMonthID
				AND SS.AsOfDayID = @AsOfDayID_LastRun
				AND (OM.MappingDetailed = 'Unknown' OR OM.PursUnpursStatus = 'Unknown')
		
		IF	@UpdatedUnknownMappingsCount > 0 -- some unknown mappings updated, yaay!
			BEGIN
				IF @UnknownMappingsCount = 0 -- zero unknown mappings left in dim table, yaay! yaay!
				-- green signal
				BEGIN
					SELECT @RefreshUnknownMappingsFlag = 1, @BoardReportingRunFlag = CASE WHEN @CurrentSnapshotsCount = 1 THEN 1 ELSE 0 END 
					SELECT @Log_Message = 'Pat completed ALL ' + CONVERT(VARCHAR,@UpdatedUnknownMappingsCount) + ' Unknown Operations Mappings update! Reload Snapshot with the updated Operations Mappings data using prior run AsOfDayID. @RefreshUnknownMappingsFlag = 1, @BoardReportingRunFlag = ' + ISNULL(CONVERT(VARCHAR,@BoardReportingRunFlag),0) + ISNULL('. @AsOfDayID_LastRun = ' + CONVERT(VARCHAR,@AsOfDayID_LastRun) + '. ', 'N/A') + ISNULL(', @CurrentSnapshotsCount = ' + CAST(@CurrentSnapshotsCount AS VARCHAR) + '. ', '') 
					EXEC   Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

				END
				ELSE
				-- wait!
				BEGIN
					SELECT @RefreshUnknownMappingsFlag = 0 
					SELECT @Log_Message = 'Pat has still ' + CONVERT(VARCHAR,@UnknownMappingsCount) + ' Unknown Operations Mappings update left! Wait for now. ' + ISNULL('@AsOfDayID_LastRun = ' + CONVERT(VARCHAR,@AsOfDayID_LastRun) + '. ', 'N/A') + ISNULL('@CurrentSnapshotsCount = ' + CAST(@CurrentSnapshotsCount AS VARCHAR) + '. ', '') 
					EXEC   Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
				END
		END

		--:: On Demand Snapshot. Board Reporting Snapshot must have been already created by this time. Is there new data in Summary fact table for this additional Snapshot? 
		IF  DATEPART(DAY,@Now) >= @BoardReportingRunStartDay
			AND @CreateSnapshotOnDemandFlag = 1 
			AND @CurrentSnapshotsCount > 0 
		BEGIN
			IF @EDW_UpdateDate_ThisRun > @EDW_UpdateDate_PrevRunThisMonth OR @EDW_UpdateDate_PrevRunThisMonth IS NULL OR @Trace_Flag = 1
			BEGIN
				SELECT @BoardReportingRunFlag = 0
				SELECT @Log_Message = 'New data! Creating one more Bubble Snapshot on demand with AsOfDayID ' + CONVERT(VARCHAR,SYSDATETIME(),112) + ' for SnapshotMonthID ' + CONVERT(VARCHAR,@SnapshotMonthID) + '. It already has ' + CAST(@CurrentSnapshotsCount AS VARCHAR) + ' Snapshot(s). The last Snapshot was created as of ' + ISNULL(CONVERT(VARCHAR,@AsOfDayID_LastRun), '') + '. @EDW_UpdateDate_PrevRunThisMonth from SummarySnapshot table = ' + ISNULL(CONVERT(VARCHAR(19),@EDW_UpdateDate_PrevRunThisMonth,121), 'N/A') + ', @EDW_UpdateDate_ThisRun from Summary table = ' + ISNULL(CONVERT(VARCHAR(19),@EDW_UpdateDate_ThisRun,121), 'N/A') 
				EXEC   Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
				IF @AsOfDayID_LastRun = CONVERT(INT,CONVERT(VARCHAR,SYSDATETIME(),112)) -- Rule: Only one Bubble Snapshot per day. We always create Bubble Snapshots only for the last month and absolutely make no changes in the snapshots created for the prior months.
				BEGIN
					--:: Backup Fact_UnifiedTransaction_SummarySnapshot
					IF OBJECT_ID('Temp.Fact_UnifiedTransaction_SummarySnapshot_DELETED','U') IS NOT NULL DROP TABLE Temp.Fact_UnifiedTransaction_SummarySnapshot_DELETED
					CREATE TABLE Temp.Fact_UnifiedTransaction_SummarySnapshot_DELETED WITH (CLUSTERED INDEX ( SnapshotMonthID ASC ), DISTRIBUTION = HASH(OperationsMappingID)) AS 
					SELECT *, CAST(SYSDATETIME() AS DATETIME2(3)) BackupDate FROM dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID AND AsOfDayID = @AsOfDayID_LastRun
					
					--:: Clear the way for reloading Board Reporting Snapshot
					DELETE dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID AND AsOfDayID = @AsOfDayID_LastRun
					SET  @Log_Message = 'Snapshot on demand run once more on the same day! Deleted existing ' + CONVERT(VARCHAR,@SnapshotMonthID) + ' Snapshot created earlier today'
					EXEC   Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
				END
			END
			ELSE
			BEGIN
				SELECT @BoardReportingRunFlag = 0, @CreateSnapshotOnDemandFlag = 0
				SELECT @Log_Message = 'No new data! Skip creating one more Bubble Snapshot on demand with AsOfDayID ' + CONVERT(VARCHAR,SYSDATETIME(),112) + ' for SnapshotMonthID ' + CONVERT(VARCHAR,@SnapshotMonthID) + '. It already has ' + CAST(@CurrentSnapshotsCount AS VARCHAR) + ' Snapshot(s). The last Snapshot was created as of ' + ISNULL(CONVERT(VARCHAR,@AsOfDayID_LastRun), '') + '. @EDW_UpdateDate_PrevRunThisMonth from SummarySnapshot table = ' + ISNULL(CONVERT(VARCHAR(19),@EDW_UpdateDate_PrevRunThisMonth,121), 'N/A') + ', @EDW_UpdateDate_ThisRun from Summary table = ' + ISNULL(CONVERT(VARCHAR(19),@EDW_UpdateDate_ThisRun,121), 'N/A') 
				EXEC   Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
			END
		END 

		IF @Trace_Flag = 1
		SELECT @SnapshotMonthID [@SnapshotMonthID], @MonthBeginDayID [@MonthBeginDayID], @SnapshotMonthID_LastRun [@SnapshotMonthID_LastRun],  @AsOfDayID_LastRun [@AsOfDayID_LastRun], @AsOfDayID_BoardReportingRun [@AsOfDayID_BoardReportingRun], @EDW_UpdateDate_PrevRunThisMonth [@EDW_UpdateDate_PrevRunThisMonth], @EDW_UpdateDate_ThisRun [@EDW_UpdateDate_ThisRun], @CurrentSnapshotsCount [@CurrentSnapshotsCount], @BoardReportingRunFlag [@BoardReportingRunFlag], @CreateSnapshotOnDemandFlag [@CreateSnapshotOnDemandFlag], @RefreshUnknownMappingsFlag [@RefreshUnknownMappingsFlag], @UpdatedUnknownMappingsCount [@UpdatedUnknownMappingsCount]

		--:: Board Reporting override run which needs clearing any existing Snapshot(s) for the last month. First Snapshot run of the current month is always meant for Board Reporting. @BoardReportingRunFlag = 1.
		IF @BoardReportingRunFlag = 1 AND EXISTS (SELECT 1 FROM dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID) 
		BEGIN
			--:: Backup Fact_UnifiedTransaction_SummarySnapshot
			IF OBJECT_ID('Temp.Fact_UnifiedTransaction_SummarySnapshot_DELETED','U') IS NOT NULL DROP TABLE Temp.Fact_UnifiedTransaction_SummarySnapshot_DELETED
			CREATE TABLE Temp.Fact_UnifiedTransaction_SummarySnapshot_DELETED WITH (CLUSTERED INDEX ( SnapshotMonthID ASC ), DISTRIBUTION = HASH(OperationsMappingID)) AS 
			SELECT *, CAST(SYSDATETIME() AS DATETIME2(3)) BackupDate FROM dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID AND AsOfDayID <= @AsOfDayID_LastRun
					
			--:: Clear the way for reloading Board Reporting Snapshot
			DELETE dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID AND AsOfDayID <= @AsOfDayID_LastRun
			SET  @Log_Message = 'Board Reporting Run override! Deleted existing ' + CONVERT(VARCHAR,@SnapshotMonthID) + ' Snapshot to clear the way for @BoardReportingRunFlag = 1 run. ' + ISNULL('@AsOfDayID_LastRun = ' + CONVERT(VARCHAR,@AsOfDayID_LastRun) + '. ', 'N/A') + ISNULL('@CurrentSnapshotsCount = ' + CAST(@CurrentSnapshotsCount AS VARCHAR) + '. ', '') 
			EXEC   Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

			--:: Discard _ThisRun backups and rename _PrevRun backups as _ThisRun. _PrevRun backups are important to stay as _PrevRun backups in this context for month over month Gold Standard diff research.
			IF OBJECT_ID('dbo.Dim_OperationsMapping_ThisRun','U') IS NOT NULL DROP TABLE dbo.Dim_OperationsMapping_ThisRun
			IF OBJECT_ID('dbo.Dim_OperationsMapping_PrevRun','U') IS NOT NULL RENAME OBJECT dbo.Dim_OperationsMapping_PrevRun TO Dim_OperationsMapping_ThisRun

			IF OBJECT_ID('dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun','U') IS NOT NULL DROP TABLE dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun
			IF OBJECT_ID('dbo.Fact_UnifiedTransaction_SummarySnapshot_PrevRun','U') IS NOT NULL RENAME OBJECT dbo.Fact_UnifiedTransaction_SummarySnapshot_PrevRun TO Fact_UnifiedTransaction_SummarySnapshot_ThisRun

			--:: No data change in these big tables when the run is only to refresh Unknown mappings updated by Pat (@RefreshUnknownMappingsFlag = 1). Why drop backup and take backup again?
			IF @RefreshUnknownMappingsFlag = 0
			BEGIN
				IF OBJECT_ID('Stage.UnifiedTransaction_ThisRun','U') IS NOT NULL DROP TABLE Stage.UnifiedTransaction_ThisRun
				IF OBJECT_ID('Stage.UnifiedTransaction_PrevRun','U') IS NOT NULL RENAME OBJECT Stage.UnifiedTransaction_PrevRun TO UnifiedTransaction_ThisRun

				IF OBJECT_ID('dbo.Fact_UnifiedTransaction_ThisRun','U') IS NOT NULL DROP TABLE dbo.Fact_UnifiedTransaction_ThisRun
				IF OBJECT_ID('dbo.Fact_UnifiedTransaction_PrevRun','U') IS NOT NULL RENAME OBJECT dbo.Fact_UnifiedTransaction_PrevRun TO Fact_UnifiedTransaction_ThisRun

				IF OBJECT_ID('dbo.Fact_UnifiedTransaction_Summary_ThisRun','U') IS NOT NULL DROP TABLE dbo.Fact_UnifiedTransaction_Summary_ThisRun
				IF OBJECT_ID('dbo.Fact_UnifiedTransaction_Summary_PrevRun','U') IS NOT NULL RENAME OBJECT dbo.Fact_UnifiedTransaction_Summary_PrevRun TO Fact_UnifiedTransaction_Summary_ThisRun
			END

		END 

		--:: Non-Board Reporting Run with @RefreshUnknownMappingsFlag = 1
		IF @BoardReportingRunFlag = 0 AND @RefreshUnknownMappingsFlag = 1 AND EXISTS (SELECT 1 FROM dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID) 
		BEGIN
			SET  @Log_Message = 'Non-Board Reporting Run! @RefreshUnknownMappingsFlag = 1. Reload existing ' + CONVERT(VARCHAR,@SnapshotMonthID) + ' Snapshot with ' + ISNULL('@AsOfDayID_LastRun = ' + CONVERT(VARCHAR,@AsOfDayID_LastRun) + '. ', '') + ISNULL('@CurrentSnapshotsCount = ' + CAST(@CurrentSnapshotsCount AS VARCHAR) + '. ', '') 
			
			--:: Backup Fact_UnifiedTransaction_SummarySnapshot
			IF OBJECT_ID('Temp.Fact_UnifiedTransaction_SummarySnapshot_DELETED','U') IS NOT NULL DROP TABLE Temp.Fact_UnifiedTransaction_SummarySnapshot_DELETED
			CREATE TABLE Temp.Fact_UnifiedTransaction_SummarySnapshot_DELETED WITH (CLUSTERED INDEX ( SnapshotMonthID ASC ), DISTRIBUTION = HASH(OperationsMappingID)) AS 
			SELECT *, CAST(SYSDATETIME() AS DATETIME2(3)) BackupDate FROM dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID AND AsOfDayID = @AsOfDayID_LastRun
					
			--:: Clear the way for reloading Board Reporting Snapshot
			DELETE dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID AND AsOfDayID = @AsOfDayID_LastRun
			SELECT @Log_Message = 'Cleared the way for refreshing Unknown Mapping updates in the last Snapshot ' + CONVERT(VARCHAR,@SnapshotMonthID) + ', saved ' + ISNULL('@AsOfDayID_LastRun = ' + CONVERT(VARCHAR,@AsOfDayID_LastRun) + '. ', '')
			EXEC   Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

		END 

		--=============================================================================================================
		-- Load dbo.Fact_UnifiedTransaction_SummarySnapshot for the last month on 4th of this month
		--=============================================================================================================

		--DECLARE @SnapshotMonthID INT = 202211, @MonthBeginDayID INT = 20221201, @RefreshUnknownMappingsFlag BIT = 0
		
		IF	@BoardReportingRunFlag = 1 OR @CreateSnapshotOnDemandFlag = 1 OR @RefreshUnknownMappingsFlag = 1 OR @Trace_Flag = 1 
		BEGIN		
			SET  @Log_Message = 'Ready to load Monthly Bubble Summary Snapshot ' + CONVERT(VARCHAR,@SnapshotMonthID) + ' with Txns before ' + CONVERT(VARCHAR,@MonthBeginDayID) + '. ' + ISNULL('@AsOfDayID = ' + CONVERT(VARCHAR,CASE WHEN @RefreshUnknownMappingsFlag = 1 THEN @AsOfDayID_LastRun ELSE CONVERT(VARCHAR,@Now,112) END) + ', ', 'N/A') + ISNULL('@CurrentSnapshotsCount = ' + CAST(@CurrentSnapshotsCount AS VARCHAR) + '. ', '')  + CASE WHEN @Trace_Flag = 1 AND NOT (@BoardReportingRunFlag = 1 OR @CreateSnapshotOnDemandFlag = 1 OR @RefreshUnknownMappingsFlag = 1) THEN '** @Trace_Flag = 1 Run **' ELSE '' END
			IF @Trace_Flag = 1 PRINT @Log_Message
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
			
			DECLARE @EDW_UpdateDate DATETIME2(3) = SYSDATETIME()

			--DECLARE @SnapshotMonthID INT = 202211, @MonthBeginDayID INT = 20221201, @EDW_UpdateDate DATETIME2(3) = SYSDATETIME()
			IF OBJECT_ID('dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW','U') IS NOT NULL DROP TABLE dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW
			CREATE TABLE dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW WITH (CLUSTERED INDEX(SnapshotMonthID), DISTRIBUTION = HASH(OperationsMappingID)) AS
			
			WITH CTE_BubbleSummarySnapshot AS
			(
			------------------------------------------------------------------
			--:: New Monthly Snapshot of the last month from current run
			------------------------------------------------------------------
			SELECT CAST(@SnapshotMonthID AS INT)			AS SnapshotMonthID
				, ISNULL(CAST(CASE WHEN @RefreshUnknownMappingsFlag = 1 THEN @AsOfDayID_LastRun ELSE CONVERT(VARCHAR,@Now,112) END AS INT), -1)	AS AsOfDayID -- Retain @AsOfDayID_LastRun, if the purpose of this run is to refresh Unknown mapping updates in the current Snapshot
				, ISNULL(TripDayID / 100,-1)				AS TripMonthID 
				, L.FacilityID
				, OperationsMappingID
				--:Begin: Key columns from dbo.Dim_OperationsMapping 
				, TripWith
				, TripIdentMethodID
				, TransactionPostingTypeID
				, TripStageID
				, TripStatusID
				, ReasonCodeID
				, CitationStageID
				, TripPaymentStatusID
				, BadAddressFlag
				, NonRevenueFlag
				, BusinessRuleMatchedFlag
				--:End: Key columns from dbo.Dim_OperationsMapping
				, ManuallyReviewedFlag
				, OOSPlateFlag
				, VTollFlag
				, ClassAdjustmentFlag
				, UTS.recordTypeID
				, ISNULL(CAST(CONVERT(VARCHAR,FirstPaidDate,112)/100 AS INT),-1)		AS FirstPaidMonthID
				, ISNULL(CAST(CONVERT(VARCHAR,LastPaidDate,112)/100 AS INT), -1)		AS LastPaidMonthID
				, Rpt_PaidvsAEA
				, SUM(TxnCount)															AS TxnCount
				, CAST(SUM(ExpectedAmount) AS DECIMAL(19,2))							AS ExpectedAmount 
				, CAST(SUM(AdjustedExpectedAmount) AS DECIMAL(19,2))					AS AdjustedExpectedAmount
				, CAST(SUM(CalcAdjustedAmount) AS DECIMAL(19,2))						AS CalcAdjustedAmount
				, CAST(SUM(TripWithAdjustedAmount) AS DECIMAL(19,2))					AS TripWithAdjustedAmount
				, CAST(SUM(TollAmount) AS DECIMAL(19,2))								AS TollAmount
				, CAST(SUM(ActualPaidAmount) AS DECIMAL(19,2))							AS ActualPaidAmount
				, CAST(SUM(OutstandingAmount) AS DECIMAL(19,2))							AS OutstandingAmount
				, MAX(LND_UpdateDate)													AS LND_UpdateDate
				, @EDW_UpdateDate														AS EDW_UpdateDate
			FROM 
				dbo.Fact_UnifiedTransaction_Summary UTS  
				JOIN dbo.Dim_Lane L	
					ON L.LaneID = UTS.LaneID
			WHERE TripDayID < @MonthBeginDayID -- First day of current month
			GROUP BY 
				  TripDayID / 100
				, TripWith
				, L.FacilityID
				, OperationsMappingID
				--:Begin: Key columns from dbo.Dim_OperationsMapping 
				, TripWith
				, TripIdentMethodID
				, TransactionPostingTypeID
				, TripStageID
				, TripStatusID
				, ReasonCodeID
				, CitationStageID
				, TripPaymentStatusID
				, BadAddressFlag
				, NonRevenueFlag
				, BusinessRuleMatchedFlag
				--:End: Key columns from dbo.Dim_OperationsMapping
				, ManuallyReviewedFlag
				, OOSPlateFlag
				, VTollFlag
				, ClassAdjustmentFlag
				, UTS.recordTypeID
				, ISNULL(CAST(CONVERT(VARCHAR,FirstPaidDate,112) AS INT)/100,-1)
				, ISNULL(CAST(CONVERT(VARCHAR,LastPaidDate,112) AS INT)/100, -1)		
				, Rpt_PaidvsAEA


			UNION ALL
		
			------------------------------------------------------------------
			--:: Static Data to cover data migration gaps
			------------------------------------------------------------------
			SELECT 
				  CAST(@SnapshotMonthID AS INT) AS SnapshotMonthID
				, ISNULL(CAST(CASE WHEN @RefreshUnknownMappingsFlag = 1 THEN @AsOfDayID_LastRun ELSE CONVERT(VARCHAR,@Now,112) END AS INT), -1)	AS AsOfDayID -- Retain @AsOfDayID_LastRun, if the purpose of this run is to refresh Unknown mapping updates in the current Snapshot
				, TripMonthID
				, FacilityID
				, SS.OperationsMappingID
				--:Begin: Key columns from dbo.Dim_OperationsMapping 
				, OM.TripWith
				, OM.TripIdentMethodID
				, OM.TransactionPostingTypeID
				, OM.TripStageID
				, OM.TripStatusID
				, OM.ReasonCodeID
				, OM.CitationStageID
				, OM.TripPaymentStatusID
				, OM.BadAddressFlag
				, OM.NonRevenueFlag
				, OM.BusinessRuleMatchedFlag
				--:End: Key columns from dbo.Dim_OperationsMapping
				, CAST(-1 AS SMALLINT)			AS ManuallyReviewedFlag
				, CAST(-1 AS SMALLINT)			AS OOSPlateFlag
				, CAST(-1 AS SMALLINT)			AS VTollFlag
				, CAST(-1 AS SMALLINT)			AS ClassAdjustmentFlag
				, -1							AS RecordTypeID
				, -1							AS FirstPaidMonthID
				, -1							AS LastPaidMonthID
				, CAST('UNK' AS VARCHAR(4))		AS Rpt_PaidvsAEA			
				, TxnCount
				, ExpectedAmount
				, AdjustedExpectedAmount
				, CalcAdjustedAmount
				, TripWithAdjustedAmount
				, TollAmount
				, ActualPaidAmount
				, OutstandingAmount
				, CAST(NULL AS DATETIME2(3))	AS LND_UpdateDate
				, @EDW_UpdateDate				AS EDW_UpdateDate
			FROM 
				Ref.Fact_UnifiedTransaction_StaticSummary SS
				JOIN dbo.Dim_OperationsMapping OM ON SS.OperationsMappingID = OM.OperationsMappingID
			)
			
			--SELECT * FROM CTE_BubbleSummarySnapshot SS
			
			--// End of CTE //

			--------------------------------------------------------------------
			--:1: Keep previous monthly snapshots intact
			--------------------------------------------------------------------
			SELECT 
				  SnapshotMonthID
				, AsOfDayID
				, RowSeq
				, TripMonthID
				, FacilityID
				, FacilityCode
				, OperationsAgency
				, OperationsMappingID
				--:Begin: Mapping output columns 
				, Mapping
				, MappingDetailed
				, PursUnpursStatus
				--:End: Mapping output columns 
				, TripWith
				, TripIdentMethodID
				, RecordTypeID
				, TransactionPostingTypeID
				, TripStageID
				, TripStatusID
				, ReasonCodeID
				, CitationStageID
				, TripPaymentStatusID
				, SourceName
				, BadAddressFlag
				, NonRevenueFlag
				, BusinessRuleMatchedFlag
				, ManuallyReviewedFlag
				, OOSPlateFlag
				, VTollFlag
				, ClassAdjustmentFlag
				, FirstPaidMonthID
				, LastPaidMonthID
				, Rpt_PaidvsAEA
				, Rpt_PurUnP
				, Rpt_LPState
				, Rpt_InvUnInv
				, Rpt_VToll
				, Rpt_IRStatus
				, Rpt_ProcessStatus
				, Rpt_PaidStatus
				, Rpt_IRRejectStatus
				, TxnCount
				, ExpectedAmount
				, AdjustedExpectedAmount
				, CalcAdjustedAmount
				, TripWithAdjustedAmount
				, TollAmount
				, ActualPaidAmount
				, OutstandingAmount
				, LND_UpdateDate
				, EDW_UpdateDate
			FROM 
				dbo.Fact_UnifiedTransaction_SummarySnapshot 
			WHERE   
				SnapshotMonthID <= @SnapshotMonthID -- If BoardReporting "override" run or Unknown mapping refresh run, note that we already purged existing snapshots for the last month above. 
				AND AsOfDayID <= @AsOfDayID_LastRun -- If SnapshotOnDemand run, all existing snapshots are copied "as is"

			UNION ALL

			------------------------------------------------------------------
			--:2: New Monthly Snapshot of the last month from current run
			------------------------------------------------------------------
			SELECT 
				  SS.SnapshotMonthID
				, SS.AsOfDayID 
				, CAST(ROW_NUMBER() OVER (PARTITION BY SS.SnapshotMonthID, SS.AsOfDayID ORDER BY CASE WHEN OM.Mapping  LIKE '%migrated%' THEN 2 ELSE 1 END, SS.TripMonthID DESC, F.FacilityCode, SS.OperationsMappingID,  SS.OOSPlateFlag, SS.ManuallyReviewedFlag, SS.ClassAdjustmentFlag, SS.RecordTypeID, SS.FirstPaidMonthID, SS.LastPaidMonthID, SS.Rpt_PaidvsAEA, SS.TxnCount DESC, SS.ExpectedAmount DESC) AS INT) RowSeq
				, SS.TripMonthID
				, SS.FacilityID
				, F.FacilityCode
				, OM.OperationsAgency
				, SS.OperationsMappingID
				--:Begin: Mapping output columns 
				, OM.Mapping
				, OM.MappingDetailed
				, OM.PursUnpursStatus
				--:End: Mapping output columns 
				, SS.TripWith
				, SS.TripIdentMethodID
				, SS.RecordTypeID
				, SS.TransactionPostingTypeID
				, SS.TripStageID
				, SS.TripStatusID
				, SS.ReasonCodeID
				, SS.CitationStageID
				, SS.TripPaymentStatusID
				, OM.SourceName
				, SS.BadAddressFlag
				, SS.NonRevenueFlag
				, SS.BusinessRuleMatchedFlag
				, SS.ManuallyReviewedFlag
				, SS.OOSPlateFlag
				, SS.VTollFlag
				, SS.ClassAdjustmentFlag
				, SS.FirstPaidMonthID
				, SS.LastPaidMonthID
				--:: New columns
				, SS.Rpt_PaidvsAEA
				, CASE  OM.TripIdentMethodID 
							WHEN -1  THEN -- This is for the static data
								CASE	WHEN OM.MappingDetailed LIKE '%Duplicate%'																	THEN 'Dupl'
										WHEN OM.MappingDetailed LIKE '%NonRev%'																		THEN 'NonRev'
										WHEN OM.MappingDetailed  = 'Video - Not Migrated Exc/Clsd Post Inv'											THEN 'Purs'
										ELSE 'UnPurs'
								END
							ELSE -- Now let's deal with the current data
								 CASE	WHEN (OM.TripStatusCode LIKE '%DUPL%' OR OM.TripStatusDesc LIKE '%DUPL%' OR OM.ReasonCode LIKE '%DUPL%') 
											 OR ( OM.TripIdentMethodID = 1  and OM.SourceName = 'TSA_OWNER.TRANSACTION_FILE_DETAILS' )				then	'Dupl'  -- Check this part again
										when OM.NonRevenueFlag = 1																					then	'NonRev'
										when OM.OperationsAgency = 'IOP - NTTA Home'																then	'NTTA-Home Agency IOP'
										when OM.TripPaymentStatusDesc in ('Paid', 'Partially Paid','Bankruptcy Discharged')
											 or OM.TripStatusCode in ('POSTED', 'ADJUSTED','ADJUSTMENT_INITIATED','CREDITADJUSTMENT','CSR_ADJUSTED','CSR_DISMISSED','DISMISSED','DISPUTE_ADJUSTED','Dispute_Dismissed','DISPUTE_INITIATED','HOLD','Reset','TOBEPAIDBYDCB','TRANSFERRED','Transitioned','UnMatch_Initiated','UNMATCHED','UNMATCHED','VTOLL')
											  or OM.ReasonCode in ('POSTED', 'PostedWithCalculationError')											then 'Purs'
										when OM.TripStatusCode in('ERROR','FORMATERROR','FUTURETRIP','IMAGE_REVIEW_PENDING','INVALID_IMAGE','INVALIDPLATE','MANUAL_REVIEW_PENDING','NEGATIVEBALANCE','PREPROCESS_DONE','REJECTED','SYSTEM_ERROR','TOOOLDTRIP','WAITING_FOR_IOP')
											 or OM.TripPaymentStatusDesc in ('NOT APPLICABLE', 'Not Paid', 'Unknown')
																																					then 'UnPurs'
										else
																																					'Unknown'
								end
					end Rpt_PurUnP
				, CASE WHEN SS.OOSPlateFlag = 0 THEN 'IS'
					   WHEN SS.OOSPlateFlag = 1 THEN 'OOS'
					   WHEN SS.OOSPlateFlag = -1 THEN 'UNK'
 				  END  Rpt_LPState
				, CASE WHEN OM.Mapping IN ('VIDEO','IOP - Video','NTTA-Home Agency IOP') AND OM.CitationStageCode IN ('CTNISSD','FSTNTV','LAPNTV','SECNTV','THDNTV','ZCN') -- 1
				  	   THEN 'Inv'
				  	   WHEN OM.Mapping IN ('VIDEO','IOP - Video','NTTA-Home Agency IOP') AND OM.CitationStageCode IN ('INVOICE','Unknown')-- 2
				  	   THEN 'UnInv'	-- 2
					   ELSE 'Unknown'
				  END  Rpt_InvUnInv 
				, CASE WHEN OM.TransactionPostingType LIKE 'VToll%'  
				  	   THEN OM.TransactionPostingType
					   WHEN OM.Mapping = 'IOP - Video'
					   THEN 'VToll'
					   WHEN OM.Mapping = 'VIDEO' AND OM.TransactionPostingType = 'NTTA Fleet' AND OM.TripStatusCode = 'VTOLL'
					   THEN 'VToll'
					   WHEN OM.Mapping = 'VIDEO' AND OM.TransactionPostingType = 'Prepaid AVI' AND OM.TripStatusCode IN ('CSR_ADJUSTED','DISPUTE_ADJUSTED','POSTED','UNMATCHED')
					   THEN 'VToll?'
					   ELSE 'Unknown'
				  END  Rpt_VToll 
				  ,case when	OM.TripStatusCode = 'REJECTED' and ReasonCode in ( 'IMAGE_INFORMATION_MISSING','IMAGE_NOT_REQUESTED','IMAGES_NOT_RECEIVED_FROM_LANES','IMI Image Metadata Not Available','No Image Available At Record Level',
																			'No Image Available At Subscriber','VES_SERIAL_NUM_NOT_EXISTS')
																						then 'No Image'
						when	OM.TripStatusCode in ('IMAGE_REVIEW_PENDING','MANUAL_REVIEW_PENDING','PREPROCESS_DONE') 
																						then	'Pending'
						when	SS.ManuallyReviewedFlag = 1								
																						then	'MIR'
						when	SS.ManuallyReviewedFlag = 0								
																						then	'OCR'
						else																	'Unknown'
				   end	as Rpt_IRStatus
				   , case	
						when	OM.CitationStageCode = 'ZCN'		then	'Zc'
						when	OM.CitationStageCode = 'FSTNTV'		then	'Fn'
						when	OM.CitationStageCode = 'SECNTV'		then	'Sn'
						when	OM.CitationStageCode = 'THDNTV'		then	'Tn/Ca'
						when	OM.CitationStageCode = 'LAPNTV'		then	'LAP'
						when	OM.CitationStageCode = 'CTNISSD'	then	'Cit'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode = 'DMVPEND'	AND	OM.ReasonCode in ('DMVPEND','IMAGE_REVIEW_PENDING','No Image Available At Subscriber')
																	then	'<>DMV'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode = 'REJECTED'	AND	OM.ReasonCode in ('DMVPEND','DMVDATANOTFOUND','DMV data not found')
																	then	'<>DMV'
						when	OM.CitationStageCode = 'Unknown'	AND		TripStatusDesc = 'Customer Balance In Delinquent State'
																	then	'Delq'
						when	OM.CitationStageCode = 'INVOICE'	AND		OM.TripStatusCode in ('CSR_DISMISSED','DISMISSED','Dispute_Dismissed')	AND TripPaymentStatusCode = 'NA'
																	then	'Dismissed'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode in ('CSR_DISMISSED','DISMISSED','Dispute_Dismissed')		AND OM.ReasonCode in( 'Unknown', 'Posted')
																	then	'Dismissed'

						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode in ('ERROR','FORMATERROR','FUTURETRIP','SYSTEM_ERROR','TOOOLDTRIP')
																	then	'Error'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode ='REJECTED'	AND	OM.ReasonCode in ('Error', 'INVALIDPLATE')
																	then	'Error'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode ='WAITING_FOR_IOP'	AND	OM.ReasonCode in ('FORMATERROR','INVALIDPLATE','SYSTEM_ERROR','TAG/PLATE_NOT_ON_FILE','TOOOLDTRIP')
																	then	'Error'

						when	OM.CitationStageCode = 'INVOICE'	AND		OM.TripStatusCode in ('CSR_ADJUSTED','DISPUTE_ADJUSTED','Excused','POSTED','TRANSFERRED','Transitioned','UNMATCHED','CSR_DISMISSED') AND TripPaymentStatusCode in ('NA')
																	then	'Excused'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode = 'Excused'	AND OM.ReasonCode = 'Posted'
																	then	'Excused'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode in('INVALID_IMAGE','REJECTED', 'POSTED')	AND OM.ReasonCode in ('Image Not Clear','Unclear Image')
																	then	'Image Not Clear'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode in('INVALID_IMAGE','REJECTED', 'POSTED','Excused')	AND OM.ReasonCode in ('Incomplete Image','Incomplete')
																	then	'Incomplete Image'

						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode in('NEGATIVEBALANCE','WAITING_FOR_IOP')	AND OM.ReasonCode = 'NEGATIVEBALANCE'
																	then	'Negative Balance'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode in('DISPUTE_ADJUSTED','INVALID_IMAGE','REJECTED','POSTED','CSR_ADJUSTED')	AND OM.ReasonCode in ('Image Not Available at Record Level','No Image Available',
																																									'IMAGE_INFORMATION_MISSING','IMAGES_NOT_RECEIVED_FROM_LANES',
																																									'IMI Image Metadata Not Available','No Image Available At Record Level',
																																									'No Image Available At Subscriber','VES_SERIAL_NUM_NOT_EXISTS')
																	then	'No Image'

						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode = 'REJECTED'		AND OM.ReasonCode = 'No Plate'
																	then	'No Plate'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode in ('REJECTED','POSTED')		AND OM.ReasonCode in ('Out of Country','Out of Country Plate')
																	then	'Out of  Country'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode in ('IMAGE_REVIEW_PENDING','MANUAL_REVIEW_PENDING')	
																	then	'Pend'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode in('DISPUTE_ADJUSTED','POSTED')		AND OM.ReasonCode = 'IMAGE_REVIEW_PENDING'
																	then	'Pend'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode in ('INVALID_IMAGE','REJECTED','POSTED','Excused','Transitioned')		AND OM.ReasonCode = 'Plate Obstruction'
																	then	'Plate Obstruction'
						when	OM.CitationStageCode in('INVOICE', 'Unknown')		AND		OM.TripStatusCode in('POSTED','Excused')		AND OM.ReasonCode in ( 'DMVDATANOTFOUND','DMVPEND')
																	then	'<>DMV'
						when	OM.CitationStageCode in('INVOICE', 'Unknown')		AND		OM.TripStatusCode in ('ADJUSTED','CSR_ADJUSTED','DISPUTE_ADJUSTED','DISPUTE_INITIATED','HOLD','UnMatch_Initiated','ADJUSTMENT_INITIATED'
																								,'CREDITADJUSTMENT','DMVPEND','TRANSFERRED','Transitioned','UNMATCHED','POSTED', 'TSA_ADJUSTED')
																										AND OM.ReasonCode in( 'POSTED','UNMATCHED', 'Unknown', 'PostedWithCalculationError','Transaction Reversal - Adjustment')
																	then	'Posted'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode = 'REJECTED'		AND OM.ReasonCode in ('Adjustment Debit cannot be processed','EMERGENCY_MODE_PAYMENT',
																															'IMAGE_NOT_REQUESTED','Invalid Transaction Type','INVALID_CUSTOMER_STATUS',
																															'Re-submission Not Allowed','Transaction Older than the configured value',
																															'Txn Field Format Invalid_"Field Name"','Txn Field Format Invalid_"ResubmitCount"',
																															'Unknown','Vehicle Misclassification by Subscriber','First Responder','Resubmittal Count is Greater than the configured value')
																	then	'Rejected'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode in ('INVALID_IMAGE','REJECTED')		AND OM.ReasonCode = 'Rejected Paper Plate'
																	then	'Rejected Paperplate'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode = 'REJECTED'		AND OM.ReasonCode in ('Tribal Plate','Tribal State Plate')
																	then	'Tribal Plate'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode in ('INVALIDPLATE','REJECTED')		AND OM.ReasonCode = 'Unknown State'
																	then	'Unknown State'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode = 'UNMATCHED'		AND OM.ReasonCode = 'Unknown'
																	then	'Unmatch'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode = 'REJECTED'		AND OM.ReasonCode in('Government','US Government Plate')
																	then	'US Govt Plate'
						when	OM.CitationStageCode in('INVOICE', 'Unknown')	AND		OM.TripStatusCode in ('POSTED','REJECTED')		AND OM.ReasonCode in('Veterans Program','Veteran Program')
																	then	'Vet'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode = 'WAITING_FOR_IOP'		AND OM.ReasonCode in ( 'IOP_PLATE','IOP_TAG','TAG/PLATE_NOT_ON_FILE','Unknown')
																	then	'Waiting For IOP'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode like 'Dupl%' -- Duplicate, Duplicate_At_Violator_Level
																	then	'Duplicate'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode in('Posted', 'Excused', 'Rejected', 'Unmatched')		AND OM.ReasonCode like 'Dupl%'
																	then	'Duplicate'
						when	OM.CitationStageCode = 'Unknown'	AND		OM.TripStatusCode = 'PREPROCESS_DONE'	
																	then	'Preprocess'
						else 'Unknown'
					end	as Rpt_ProcessStatus
					,case 
						when OM.TripPaymentStatusCode = 'BkrtDismiss' 
													then	'Bnkrpt Discharg'
						when OM.TripPaymentStatusCode = 'NotPaid' 
													then	'Not Paid'
						when OM.TripPaymentStatusCode = 'Paid' 
													then	'Paid'
						when OM.TripPaymentStatusCode = 'PartialPaid' 
													then	'Partial paid'
						when OM.TripPaymentStatusCode = 'NA'  AND OM.TripStatusCode in ('CSR_ADJUSTED','DISPUTE_ADJUSTED','DISPUTE_INITIATED','Excused','POSTED','Reset','TRANSFERRED','Transitioned','UNMATCHED')
													then	'Execused'
						when OM.TripPaymentStatusCode = 'NA'  AND OM.TripStatusCode in ('CSR_DISMISSED','DISMISSED','Dispute_Dismissed','Transaction Dismissed')
													then	'Dismissed'
						when OM.TripPaymentStatusCode in ('NA', 'Unknown' )  AND  SS.Rpt_PaidVsAEA = '0'  
													then 'UnPaid'
						when OM.TripPaymentStatusCode in ('NA', 'Unknown' ) AND  SS.Rpt_PaidVsAEA in (	'<AEA','=AEA','>AEA')
													then 'Paid'
						else 'Unknown'
					end as Rpt_PaidStatus
					,case
						when	OM.PursUnpursStatus like 'Dupl%' then  'Unknown'
						when	OM.TripIdentMethod = 'AVITOLL' then  'Unknown'
						when	OM.TripStatusCode in ('IMAGE_REVIEW_PENDING','MANUAL_REVIEW_PENDING','PREPROCESS_DONE') then 'Pending'
						when	OM.Mapping in ('VIDEO','IOP - Video','NTTA-Home Agency IOP') AND OM.TripStatusCode in
										('ADJUSTED','ADJUSTMENT_INITIATED','CREDITADJUSTMENT','CSR_ADJUSTED','CSR_DISMISSED','DISMISSED','DISPUTE_ADJUSTED',
										'Dispute_Dismissed','DISPUTE_INITIATED','DMVPEND','Excused','HOLD','NEGATIVEBALANCE','POSTED','Reset','TOBEPAIDBYDCB',
										'TRANSFERRED','Transitioned','UnMatch_Initiated','UNMATCHED','VTOLL')	then 'IA'
						when	OM.Mapping in ('VIDEO','IOP - Video','NTTA-Home Agency IOP') 	AND OM.TripStatusCode in 
										('ERROR','FORMATERROR','FUTURETRIP','INVALID_IMAGE','INVALIDPLATE','SYSTEM_ERROR','TOOOLDTRIP')	then 'IR'
						when	OM.Mapping in ('VIDEO','IOP - Video','NTTA-Home Agency IOP') AND OM.TripStatusCode = 'REJECTED' AND OM.ReasonCode in
										('DMV data not found','DMVDATANOTFOUND','DMVPEND')	then	'IA'
						when	OM.Mapping in ('VIDEO','IOP - Video','NTTA-Home Agency IOP') AND OM.TripStatusCode = 'REJECTED' AND OM.ReasonCode not in
										('DMV data not found','DMVDATANOTFOUND','DMVPEND')	then	'IR'
						when	OM.Mapping in ('VIDEO','IOP - Video','NTTA-Home Agency IOP') AND OM.TripStatusCode = 'WAITING_FOR_IOP' AND OM.ReasonCode not in
										('IOP_PLATE','NEGATIVEBALANCE','TAG/PLATE_NOT_ON_FILE')	then	'IA'
						when	OM.Mapping in ('VIDEO','IOP - Video','NTTA-Home Agency IOP') AND OM.TripStatusCode = 'WAITING_FOR_IOP' AND ReasonCode not in
										('SYSTEM_ERROR','TOOOLDTRIP','Unknown')	then	'IR'
						else	'Unknown'
					end as Rpt_IRRejectStatus

				--:: Metrics
				, SS.TxnCount
				, SS.ExpectedAmount
				, SS.AdjustedExpectedAmount
				, SS.CalcAdjustedAmount
				, SS.TripWithAdjustedAmount
				, SS.TollAmount
				, SS.ActualPaidAmount
				, SS.OutstandingAmount
				, SS.LND_UpdateDate
				, SS.EDW_UpdateDate
			FROM CTE_BubbleSummarySnapshot SS
				JOIN dbo.Dim_Facility F
					ON F.FacilityID = SS.FacilityID
				JOIN dbo.Dim_OperationsMapping OM
					ON OM.OperationsMappingID = SS.OperationsMappingID
					
			OPTION (LABEL = 'Fact_UnifiedTransaction_SummarySnapshot_NEW Load');
            
			SET  @Log_Message = 'Loaded dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW for @SnapshotMonthID ' + CONVERT(VARCHAR,@SnapshotMonthID)
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

			--:: Create Statistics
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_001 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(SnapshotMonthID)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_002 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(TripMonthID)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_003 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(OperationsMappingID)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_004 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(TripWith)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_005 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(TripIdentMethodID)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_006 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(TransactionPostingTypeID)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_007 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(TripStageID)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_008 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(TripStatusID)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_009 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(ReasonCodeID)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_010 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(CitationStageID)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_011 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(TripPaymentStatusID)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_012 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(BadAddressFlag)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_013 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(NonRevenueFlag)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_014 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(BusinessRuleMatchedFlag)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_015 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(ManuallyReviewedFlag)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_016 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(OOSPlateFlag)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_017 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(FacilityID)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_018 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(ExpectedAmount)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_019 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(ActualPaidAmount)	
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_020 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(FirstPaidMonthID)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_021 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(LastPaidMonthID)	
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_022 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(Rpt_PaidvsAEA)	
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_023 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(Rpt_InvUnInv)	
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_024 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(Rpt_LPState)	
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_025 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(Rpt_VToll)	
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_026 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(VTollFlag)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_027 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(ClassAdjustmentFlag)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_028 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(Mapping)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_029 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(MappingDetailed)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_030 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(PursUnpursStatus)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_031 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(OperationsAgency)
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_032 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(FacilityCode )
			CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_033 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW(RowSeq )
		
			SET  @Log_Message = 'Created STATISTICS on dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW' 
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

			-- Table swap!
			EXEC Utility.TableSwap 'dbo.Fact_UnifiedTransaction_SummarySnapshot_NEW', 'dbo.Fact_UnifiedTransaction_SummarySnapshot'
		
			--:: Return the latest BubbleSummarySnapshot dataset for CSV file output
			IF	@RefreshUnknownMappingsFlag = 1 -- BoardReportingRun override with 0 Unknown OperationsMapping rows
				OR (@BoardReportingRunFlag = 1 AND @UnknownMappingsCount = 0) -- BoardReportingRun directly with 0 Unknown OperationsMapping rows
			BEGIN
				SELECT @AsOfDayID_LastRun = MIN(AsofDayID) FROM dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID
				SELECT * FROM dbo.vw_BubbleSummarySnapshot_OldNames WHERE SnapshotMonthID = @SnapshotMonthID AND AsofDayID = @AsOfDayID_LastRun ORDER BY SnapshotMonthID, AsOfDayID, RowSeq
				SELECT @Log_Message = 'Created CSV file output for Monthly Bubble Summary Snapshot ' + CONVERT(VARCHAR,@SnapshotMonthID) + ' As Of ' + CONVERT(VARCHAR,SYSDATETIME(),112)  + '. @RefreshUnknownMappingsFlag = 1'
				EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
			END

			--=============================================================================================================
			--:: Preserve the tables for Snapshot data validation afterwards
			--=============================================================================================================
			IF  @BoardReportingRunFlag = 1 /*means, prod run on 4th of the month or override Board Reporting Snapshot run*/
				OR (@Trace_Flag = 1 AND @Backup_Flag = 1)
			BEGIN
				--:: Backup dbo.Fact_UnifiedTransaction_SummarySnapshot
				IF OBJECT_ID('dbo.Fact_UnifiedTransaction_SummarySnapshot_PrevRun','U') IS NOT NULL DROP TABLE dbo.Fact_UnifiedTransaction_SummarySnapshot_PrevRun
				IF OBJECT_ID('dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun','U') IS NOT NULL RENAME OBJECT dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun TO Fact_UnifiedTransaction_SummarySnapshot_PrevRun
				CREATE TABLE dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun WITH (CLUSTERED INDEX ( SnapshotMonthID ASC ), DISTRIBUTION = HASH(OperationsMappingID)) AS
				SELECT *, CAST(SYSDATETIME() AS DATETIME2(3)) BackupDate FROM dbo.Fact_UnifiedTransaction_SummarySnapshot 
				OPTION (LABEL = 'dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun Load') 

				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_001 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (SnapshotMonthID);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_002 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (TripMonthID);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_003 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (OperationsMappingID);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_004 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (TripWith);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_005 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (TripIdentMethodID);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_006 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (TransactionPostingTypeID);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_007 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (TripStageID);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_008 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (TripStatusID);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_009 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (ReasonCodeID);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_010 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (CitationStageID);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_011 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (TripPaymentStatusID);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_012 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (BadAddressFlag);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_013 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (NonRevenueFlag);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_014 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (BusinessRuleMatchedFlag);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_015 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (ManuallyReviewedFlag);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_016 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (OOSPlateFlag);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_017 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (FacilityID);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_018 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (ExpectedAmount);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_019 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (ActualPaidAmount);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_020 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (FirstPaidMonthID);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_021 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (LastPaidMonthID);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_022 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (Rpt_PaidvsAEA);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_023 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (Rpt_InvUnInv);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_024 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (Rpt_LPState);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_025 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (Rpt_VToll);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_026 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (VTollFlag);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_027 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (ClassAdjustmentFlag);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_028 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (Mapping);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_029 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (MappingDetailed);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_030 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (PursUnpursStatus);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_031 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (OperationsAgency);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_032 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (FacilityCode);
				CREATE STATISTICS STATS_Fact_UnifiedTransaction_SummarySnapshot_033 ON dbo.Fact_UnifiedTransaction_SummarySnapshot_ThisRun (RowSeq);
				
				SET  @Log_Message = 'Backup dbo.Fact_UnifiedTransaction_SummarySnapshot after the Monthly Snapshot'
				EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

				--:: Backup dbo.Dim_OperationsMapping
				IF OBJECT_ID('dbo.Dim_OperationsMapping_PrevRun','U') IS NOT NULL DROP TABLE dbo.Dim_OperationsMapping_PrevRun
				IF OBJECT_ID('dbo.Dim_OperationsMapping_ThisRun','U') IS NOT NULL RENAME OBJECT dbo.Dim_OperationsMapping_ThisRun TO Dim_OperationsMapping_PrevRun
				CREATE TABLE dbo.Dim_OperationsMapping_ThisRun WITH (CLUSTERED INDEX (OperationsMappingID), DISTRIBUTION = REPLICATE) AS
				SELECT *, CAST(SYSDATETIME() AS DATETIME2(3)) BackupDate FROM dbo.Dim_OperationsMapping

				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_001 ON dbo.Dim_OperationsMapping_ThisRun (TripIdentMethod)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_002 ON dbo.Dim_OperationsMapping_ThisRun (TripWith)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_003 ON dbo.Dim_OperationsMapping_ThisRun (TransactionPostingType)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_004 ON dbo.Dim_OperationsMapping_ThisRun (TripStageCode)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_005 ON dbo.Dim_OperationsMapping_ThisRun (TripStatusCode)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_006 ON dbo.Dim_OperationsMapping_ThisRun (ReasonCode)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_007 ON dbo.Dim_OperationsMapping_ThisRun (CitationStageCode)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_008 ON dbo.Dim_OperationsMapping_ThisRun (TripPaymentStatusDesc)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_009 ON dbo.Dim_OperationsMapping_ThisRun (SourceName)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_010 ON dbo.Dim_OperationsMapping_ThisRun (OperationsAgency)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_011 ON dbo.Dim_OperationsMapping_ThisRun (BadAddressFlag)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_012 ON dbo.Dim_OperationsMapping_ThisRun (NonRevenueFlag)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_013 ON dbo.Dim_OperationsMapping_ThisRun (BusinessRuleMatchedFlag)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_014 ON dbo.Dim_OperationsMapping_ThisRun (TripIdentMethodID)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_015 ON dbo.Dim_OperationsMapping_ThisRun (TransactionPostingTypeID)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_016 ON dbo.Dim_OperationsMapping_ThisRun (TripStageID)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_017 ON dbo.Dim_OperationsMapping_ThisRun (TripStatusID)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_018 ON dbo.Dim_OperationsMapping_ThisRun (ReasonCodeID)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_019 ON dbo.Dim_OperationsMapping_ThisRun (CitationStageID)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_020 ON dbo.Dim_OperationsMapping_ThisRun (TripPaymentStatusID)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_021 ON dbo.Dim_OperationsMapping_ThisRun (Mapping)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_022 ON dbo.Dim_OperationsMapping_ThisRun (MappingDetailed)
				CREATE STATISTICS STATS_dbo_Dim_OperationsMapping_023 ON dbo.Dim_OperationsMapping_ThisRun (PursUnpursStatus)

				SET  @Log_Message = 'Backup dbo.Dim_OperationsMapping after the Monthly Snapshot'
				EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

				--:: Saving Pat's time. Purge Unknown mappings which carry no Txns in the entire Bubble Snapshot fact table and thus, no value.  
				DELETE FROM dbo.Dim_OperationsMapping 
				WHERE EDW_UpdateDate > DATEADD (DAY,1,EOMONTH(GETDATE( ),-2)) -- First day of the last month
				AND NOT EXISTS (SELECT 1 FROM dbo.Fact_UnifiedTransaction_SummarySnapshot ss WHERE Dim_OperationsMapping.OperationsMappingID = ss.OperationsMappingID) 
				AND MappingDetailed = 'Unknown' -- This is when Pat not yet updated Unknown mappings for those rows having no Txns in the entire Bubble Snapshot fact table

				SET  @Log_Message = 'Deleted new Unknown mapping rows in dbo.Dim_OperationsMapping which do not map to any Txns in the entire Bubble Snapshot fact table'
				EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

				IF @RefreshUnknownMappingsFlag = 0 -- First run, not the subsequent run after Pat updated Unknown mappings. Save time in DEV by not touching these backup tables after monthly APS2 DB refresh!
				BEGIN 
					--:: Backup Stage.UnifiedTransaction
					IF OBJECT_ID('Stage.UnifiedTransaction_PrevRun','U') IS NOT NULL DROP TABLE Stage.UnifiedTransaction_PrevRun
					IF OBJECT_ID('Stage.UnifiedTransaction_ThisRun','U') IS NOT NULL RENAME OBJECT Stage.UnifiedTransaction_ThisRun TO UnifiedTransaction_PrevRun
					CREATE TABLE stage.UnifiedTransaction_ThisRun WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), 
							PARTITION (TripDayID RANGE RIGHT FOR VALUES (   20190101,20190401,20190701,20191001,
																			20200101,20200401,20200701,20201001,
																			20210101,20210401,20210701,20211001,
																			20220101,20220401,20220701,20221101,
																			20230101,20230401,20230901,20231001,
																			20240101,20240401,20240901,20241001
																		)))
					AS 																	
					SELECT *, CAST(SYSDATETIME() AS DATETIME2(3)) BackupDate FROM stage.UnifiedTransaction

					CREATE STATISTICS STATS_Stage_UnifiedTransaction_001 ON stage.UnifiedTransaction_ThisRun (TPTripID);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_002 ON stage.UnifiedTransaction_ThisRun (CustTripID);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_003 ON stage.UnifiedTransaction_ThisRun (CitationID);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_004 ON stage.UnifiedTransaction_ThisRun (TripIdentMethod);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_005 ON stage.UnifiedTransaction_ThisRun (TripWith);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_006 ON stage.UnifiedTransaction_ThisRun (TransactionPostingType);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_007 ON stage.UnifiedTransaction_ThisRun (TripStageCode);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_008 ON stage.UnifiedTransaction_ThisRun (TripStatusCode);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_009 ON stage.UnifiedTransaction_ThisRun (ReasonCode);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_010 ON stage.UnifiedTransaction_ThisRun (CitationStageCode);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_011 ON stage.UnifiedTransaction_ThisRun (TripPaymentStatusDesc);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_012 ON stage.UnifiedTransaction_ThisRun (SourceName);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_013 ON stage.UnifiedTransaction_ThisRun (BadAddressFlag);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_014 ON stage.UnifiedTransaction_ThisRun (NonRevenueFlag);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_015 ON stage.UnifiedTransaction_ThisRun (BusinessRuleMatchedFlag);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_016 ON stage.UnifiedTransaction_ThisRun (VESSerialNumber);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_017 ON stage.UnifiedTransaction_ThisRun (IPSTransactionID);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_018 ON stage.UnifiedTransaction_ThisRun (TripPaymentStatusID);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_019 ON stage.UnifiedTransaction_ThisRun (TripStatusID);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_020 ON stage.UnifiedTransaction_ThisRun (TripStageID);
					CREATE STATISTICS STATS_Stage_UnifiedTransaction_021 ON stage.UnifiedTransaction_ThisRun (TripDayID);

					SET  @Log_Message = 'Backup Stage.UnifiedTransaction after the Monthly Snapshot'
					EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

					--:: Backup dbo.Fact_UnifiedTransaction
					IF OBJECT_ID('dbo.Fact_UnifiedTransaction_PrevRun','U') IS NOT NULL DROP TABLE dbo.Fact_UnifiedTransaction_PrevRun
					IF OBJECT_ID('dbo.Fact_UnifiedTransaction_ThisRun','U') IS NOT NULL RENAME OBJECT dbo.Fact_UnifiedTransaction_ThisRun TO Fact_UnifiedTransaction_PrevRun
					CREATE TABLE dbo.Fact_UnifiedTransaction_ThisRun
							WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), 
							PARTITION (TripDayID RANGE RIGHT FOR VALUES (   20190101,20190401,20190701,20191001,
																			20200101,20200401,20200701,20201001,
																			20210101,20210401,20210701,20211001,
																			20220101,20220401,20220701,20221101,
																			20230101,20230401,20230901,20231001,
																			20240101,20240401,20240901,20241001
																		))) 
					AS 
					SELECT *, CAST(SYSDATETIME() AS DATETIME2(3)) BackupDate FROM dbo.Fact_UnifiedTransaction
					OPTION (LABEL = 'dbo.Fact_UnifiedTransaction_ThisRun Load') 

					--:: Create Statistics
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_001 ON dbo.Fact_UnifiedTransaction_ThisRun(TpTripID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_002 ON dbo.Fact_UnifiedTransaction_ThisRun(TripDayID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_003 ON dbo.Fact_UnifiedTransaction_ThisRun(CustTripID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_004 ON dbo.Fact_UnifiedTransaction_ThisRun(CitationID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_005 ON dbo.Fact_UnifiedTransaction_ThisRun(OperationsMappingID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_006 ON dbo.Fact_UnifiedTransaction_ThisRun(TripWith)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_007 ON dbo.Fact_UnifiedTransaction_ThisRun(TripIdentMethodID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_008 ON dbo.Fact_UnifiedTransaction_ThisRun(TransactionPostingTypeID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_009 ON dbo.Fact_UnifiedTransaction_ThisRun(TripStageID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_010 ON dbo.Fact_UnifiedTransaction_ThisRun(TripStatusID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_011 ON dbo.Fact_UnifiedTransaction_ThisRun(ReasonCodeID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_012 ON dbo.Fact_UnifiedTransaction_ThisRun(CitationStageID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_013 ON dbo.Fact_UnifiedTransaction_ThisRun(TripPaymentStatusID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_014 ON dbo.Fact_UnifiedTransaction_ThisRun(TripStatusID)

					SET  @Log_Message = 'Backup dbo.Fact_UnifiedTransaction after the Monthly Snapshot'
					EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
				
					--:: Backup dbo.Fact_UnifiedTransaction_Summary
					IF OBJECT_ID('dbo.Fact_UnifiedTransaction_Summary_PrevRun','U') IS NOT NULL DROP TABLE dbo.Fact_UnifiedTransaction_Summary_PrevRun
					IF OBJECT_ID('dbo.Fact_UnifiedTransaction_Summary_ThisRun','U') IS NOT NULL RENAME OBJECT dbo.Fact_UnifiedTransaction_Summary_ThisRun TO Fact_UnifiedTransaction_Summary_PrevRun
					CREATE TABLE dbo.Fact_UnifiedTransaction_Summary_ThisRun WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TripDayID)) AS
					SELECT *, CAST(SYSDATETIME() AS DATETIME2(3)) BackupDate FROM dbo.Fact_UnifiedTransaction_Summary
					OPTION (LABEL = 'dbo.Fact_UnifiedTransaction_Summary_ThisRun Load') 
			
					--:: Create Statistics
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_001 ON dbo.Fact_UnifiedTransaction_Summary_ThisRun(TripDayID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_002 ON dbo.Fact_UnifiedTransaction_Summary_ThisRun(LaneID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_003 ON dbo.Fact_UnifiedTransaction_Summary_ThisRun(OperationsMappingID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_004 ON dbo.Fact_UnifiedTransaction_Summary_ThisRun(TripWith)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_005 ON dbo.Fact_UnifiedTransaction_Summary_ThisRun(TripIdentMethodID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_006 ON dbo.Fact_UnifiedTransaction_Summary_ThisRun(TransactionPostingTypeID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_007 ON dbo.Fact_UnifiedTransaction_Summary_ThisRun(TripStageID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_008 ON dbo.Fact_UnifiedTransaction_Summary_ThisRun(TripStatusID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_009 ON dbo.Fact_UnifiedTransaction_Summary_ThisRun(ReasonCodeID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_010 ON dbo.Fact_UnifiedTransaction_Summary_ThisRun(CitationStageID)
					CREATE STATISTICS STATS_Fact_UnifiedTransaction_Summary_011 ON dbo.Fact_UnifiedTransaction_Summary_ThisRun(TripPaymentStatusID)

					SET  @Log_Message = 'Backup dbo.Fact_UnifiedTransaction_Summary after the Monthly Snapshot'
					EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
				END
			END
		END
		ELSE
		IF EXISTS (SELECT 1 FROM dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID)
		BEGIN
			SELECT @Log_Message = 'Monthly Bubble Summary Snapshot for ' + CONVERT(VARCHAR,@SnapshotMonthID) + ' already has ' + CAST(@CurrentSnapshotsCount AS VARCHAR) + ' Snapshot(s) and the last one was created on ' + ISNULL('@AsOfDayID_LastRun = ' + CONVERT(VARCHAR,@AsOfDayID_LastRun) + '. ', 'N/A')
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
		END 

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed full load', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 EXEC Utility.FromLog @Log_Source, @Log_Start_Date
		IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Fact_UnifiedTransaction_SummarySnapshot' TableName, * FROM dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID ORDER BY 2 DESC, 3 DESC, 4,5,6,7
	
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

EXEC dbo.Fact_UnifiedTransaction_SummarySnapshot_Full_Load @BoardReportingRunFlag = 0, @CreateSnapshotOnDemandFlag = 0
SELECT * FROM Utility.ProcessLog Where LogSource = 'dbo.Fact_UnifiedTransaction_SummarySnapshot_Full_Load' ORDER BY 1 DESC

SELECT SnapshotMonthID,AsOfDayID, SUM(TxnCount) TxnCount, SUM(ExpectedAmount) ExpectedAmount, SUM(AdjustedExpectedAmount) AdjustedExpectedAmount, SUM(ActualPaidAmount) ActualPaidAmount
FROM dbo.Fact_UnifiedTransaction_SummarySnapshot
GROUP BY SnapshotMonthID, AsOfDayID
ORDER BY 1 DESC,2 

SELECT DISTINCT OperationsMappingID FROM dbo.Fact_UnifiedTransaction_SummarySnapshot  WHERE SnapshotMonthID = 202211 AND MappingDetailed = 'unknown'

SELECT TOP 1000 'dbo.Fact_UnifiedTransaction_SummarySnapshot' TableName, * FROM dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = 202211 ORDER BY SnapshotMonthID, AsOfDayID, RowSeq

--===============================================================================================================
--  Latest Bubble Snapshot Rows csv file output
--===============================================================================================================
--:: Unknown Bubble Snapshot Rows check
SELECT TOP 100 * FROM dbo.vw_BubbleSummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID AND AsOfDayID = @AsOfDayID AND (MappingDetailed = 'Unknown' OR PursUnPursStatus = 'Unknown') ORDER BY SnapshotMonthID, AsOfDayID, RowSeq
--:: Unknown mappings in Dim_OperationsMapping rows
SELECT TOP 100 * FROM dbo.Dim_OperationsMapping WHERE OperationsMappingID in (SELECT DISTINCT OperationsMappingID FROM dbo.vw_BubbleSummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID AND (MappingDetailed = 'Unknown' OR PursUnPursStatus = 'Unknown'))

-- Query for monthly Bubble csv file: \\nttafs1\Groups\NTTA\Operations-Analytics\00 Reporting\Bubble Spreadsheets Used for Board Reporting\csv\Bubble Summary Snapshot_*.csv
DECLARE @SnapshotMonthID INT, @AsofDayID INT
SELECT @SnapshotMonthID = MAX(SnapshotMonthID) FROM [dbo].[Fact_UnifiedTransaction_SummarySnapshot]
SELECT @AsofDayID = MAX(AsofDayID) FROM [dbo].[Fact_UnifiedTransaction_SummarySnapshot] WHERE SnapshotMonthID = @SnapshotMonthID
SELECT TOP 100 * FROM dbo.vw_BubbleSummarySnapshot WHERE SnapshotMonthID = @SnapshotMonthID AND AsOfDayID = @AsOfDayID ORDER BY SnapshotMonthID, AsOfDayID, RowSeq

-- See Data Manager Process 8532 in 9012 Package to refresh Unknown Mappings and export Bubble SummarySnapshot csv file

--===============================================================================================================
-- Quick check
--===============================================================================================================
DECLARE @SnapshotMonthID INT
SELECT @SnapshotMonthID = MAX(SnapshotMonthID) FROM dbo.Fact_UnifiedTransaction_SummarySnapshot

SELECT	 ut.TripMonthID/100,SUM(ut.TxnCount) TxnCount 
FROM	dbo.Fact_UnifiedTransaction_SummarySnapshot ut 
		JOIN dbo.Dim_Facility f ON f.FacilityID = ut.FacilityID 
		JOIN dbo.Dim_OperationsMapping OM ON OM.OperationsMappingID = ut.OperationsMappingID
WHERE	ut.SnapshotMonthID = 202205 AND F.FacilityCode LIKE 'NE%49'
GROUP BY ut.TripMonthID/100 o
ORDER BY 1

SELECT	ut.TripDayID/10000 TripYear, SUM(ut.TxnCount) TxnCount 
FROM	dbo.Fact_UnifiedTransaction_Summary ut 
		JOIN dbo.Dim_Lane l ON l.LaneID = ut.LaneID 
		JOIN dbo.Dim_OperationsMapping OM ON OM.OperationsMappingID = ut.OperationsMappingID
WHERE	  l.FacilityCode LIKE 'NE%49' AND ut.TripDayID < 20220601
GROUP BY ut.TripDayID/10000
ORDER BY 1

--=================================================================================================
-- Post Monthly Bubble Run data validation script. Preliminary checks.
--=================================================================================================

--:: TBOS vs LND Row Counts compare data monitor query. CreatedDate works great for majority of the tables for stable daily row count comparison between SRC and APS.
SELECT  * 
FROM    LND_TBOS.Utility.vw_CDCCompareSummary 
WHERE   NonMatching_RowCount <> 0 -->> 100 % row counts match on all days
        AND TableName NOT IN ('History.TP_Customer_Attributes','History.TP_Customers','IOP.BOS_IOP_OutboundTransactions','TollPlus.TP_Customer_Tags_History','TollPlus.TP_CustomerTrips','EIP.Results_Log','TollPlus.TP_Customer_Vehicle_Tags','TollPlus.TP_Customer_Vehicles','TollPlus.TP_Customer_Tags') 
UNION ALL
--:: CreatedDate is not suitable for some tables as new rows updated can have any old CreatedDate. Use NonMatching_RowPercent as a reasonable indicator to call for attention.
--:: Note: The pre-condition for this compare to work is that you capture SRC and APS row counts almost at the same time, never too far!
SELECT  * 
FROM    LND_TBOS.Utility.vw_CDCCompareSummary 
WHERE   NonMatching_RowPercent > 0.1 -->> 99.9% row counts match
        AND TableName IN ('History.TP_Customer_Attributes','History.TP_Customers','IOP.BOS_IOP_OutboundTransactions','TollPlus.TP_Customer_Tags_History','TollPlus.TP_CustomerTrips','EIP.Results_Log','TollPlus.TP_Customer_Vehicle_Tags','TollPlus.TP_Customer_Vehicles','TollPlus.TP_Customer_Tags') 
ORDER BY DataBaseName DESC, TableName

--Sample data check
SELECT 'Stage.UnifiedTransaction' TableName, COUNT_BIG(1) RC FROM Stage.UnifiedTransaction  
SELECT TOP 1000 'Stage.UnifiedTransaction' TableName, * FROM Stage.UnifiedTransaction --ORDER BY TripDate DESC,TPTripID
SELECT TOP 1000 'dbo.Fact_UnifiedTransaction' TableName, * FROM dbo.Fact_UnifiedTransaction --ORDER BY TripDate DESC,TPTripID
SELECT TOP 1000 'dbo.Fact_UnifiedTransaction_Summary' TableName, * FROM dbo.Fact_UnifiedTransaction_Summary --ORDER BY 2 DESC,3,4
SELECT TOP 1000 'Fact_UnifiedTransaction_SummarySnapshot' TableName, * FROM dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = 202202
ORDER BY SnapshotMonthID DESC, TripMonthID DESC, OperationsMappingID, FacilityID
SELECT 'Fact_UnifiedTransaction_SummarySnapshot' TableName, SnapshotMonthID, AsOfDayID, * FROM dbo.Fact_UnifiedTransaction_SummarySnapshot WHERE SnapshotMonthID = 202202
ORDER BY SnapshotMonthID DESC, TripMonthID DESC, OperationsMappingID, FacilityID

--::Input check on APS1 
SELECT COUNT_BIG(1) LND_TxnCount , MIN(EXITTRIPDATETIME) [TripDateFrom], MAX(EXITTRIPDATETIME) TripDateTo
FROM LND_TBOS.TollPlus.TP_Trips TT (NOLOCK)
WHERE TT.ExitTripDateTime >= '01/01/2019'
AND TT.ExitTripDateTime < '11/01/2022'  
AND TT.SourceOfEntry IN (1,3) --TSA & NTTA 
AND TT.Exit_TollTxnID >= 0
AND TT.LND_UpdateType <> 'd'

--:: Input check on TBOS. Run it in Prod TBOS source also on NPRODTBOSLSTR02 (takes 20 to 30 min). Both should match.
SELECT COUNT_BIG(1) LND_TxnCount , MIN(EXITTRIPDATETIME) [TripDateFrom], MAX(EXITTRIPDATETIME) TripDateTo
FROM TollPlus.TP_Trips TT (NOLOCK)
WHERE TT.ExitTripDateTime >= '01/01/2019'
AND TT.ExitTripDateTime < '10/01/2022'  
AND TT.SourceOfEntry IN (1,3) --TSA & NTTA 
AND TT.Exit_TollTxnID >= 0

--=================================================================================================
-- Gold Standard Testing
--=================================================================================================

--:: Pat's Gold Standard Tests XL format

-- By TripMonth
SELECT SnapshotMonthID,AsOfDayID, TripMonthID, SUM(TxnCount) TxnCount, SUM(ExpectedAmount) ExpectedAmount, SUM(AdjustedExpectedAmount) AdjustedExpectedAmount, SUM(ActualPaidAmount) ActualPaidAmount
FROM dbo.Fact_UnifiedTransaction_SummarySnapshot
WHERE SnapshotMonthID in (202210, 202211)
AND TripMonthID <= 202210
GROUP BY SnapshotMonthID, AsOfDayID, TripMonthID
ORDER BY 1 DESC,2,3

-- By MappingDetailed
SELECT SnapshotMonthID,AsOfDayID, TripMonthID, Mapping, MappingDetailed, SUM(TxnCount) TxnCount, SUM(ExpectedAmount) ExpectedAmount, SUM(AdjustedExpectedAmount) AdjustedExpectedAmount, SUM(ActualPaidAmount) ActualPaidAmount
FROM dbo.Fact_UnifiedTransaction_SummarySnapshot
WHERE SnapshotMonthID in (202210, 202211)
AND TripMonthID <= 202210
GROUP BY SnapshotMonthID, AsOfDayID, TripMonthID, Mapping, MappingDetailed
ORDER BY 1 DESC,2,3,4,5


------ 1. Gold Standard-Total Counts ------

select	'APS1 202210 vs 202211 Snapshots' SRC, SnapshotMonthID,  
		TripMonthID/100 as TripYear, 
		sum(TxnCount)  TxnCount ,
		Sum(ExpectedAmount) ExpectedAmount
from edw_trips.dbo.Fact_UnifiedTransaction_SummarySnapshot 
where SnapshotMonthID in (202210, 202211)  -- Compare last 2 snapshots
and TripMonthID <= 202210 -- remove last month from the comparison
group by SnapshotMonthID ,  TripMonthID/100  
order by TripYear DESC, SnapshotMonthID desc							

--:: Gold standard side ways diff at TripYear level
SELECT *, a.TxnCount - b.TxnCount TxnCount_Diff, a.ExpectedAmount - b.ExpectedAmount ExpectedAmount_Diff
from
(
select	SnapshotMonthID,  
		TripMonthID/100 as TripYear, 
		sum(TxnCount)  TxnCount ,
		Sum(ExpectedAmount) ExpectedAmount
from edw_trips.dbo.Fact_UnifiedTransaction_SummarySnapshot 
where SnapshotMonthID = 202210 
and TripMonthID <= 202210 -- remove last month from the comparison
group by SnapshotMonthID ,  TripMonthID/100  
) b 
JOIN 
(
select	SnapshotMonthID,  
		TripMonthID/100 as TripYear, 
		sum(TxnCount)  TxnCount ,
		Sum(ExpectedAmount) ExpectedAmount
from edw_trips.dbo.Fact_UnifiedTransaction_SummarySnapshot 
where SnapshotMonthID = 202211 
and TripMonthID <= 202210 -- remove last month from the comparison
group by SnapshotMonthID ,  TripMonthID/100  
) a ON a.TripYear = b.TripYear
ORDER by TripYear DESC 

--:: Gold standard side ways diff at TripMonth level
SELECT *, a.TxnCount - b.TxnCount TxnCount_Diff, a.ExpectedAmount - b.ExpectedAmount ExpectedAmount_Diff
from
(
select	SnapshotMonthID,  
		TripMonthID, 
		sum(TxnCount)  TxnCount ,
		Sum(ExpectedAmount) ExpectedAmount
from edw_trips.dbo.Fact_UnifiedTransaction_SummarySnapshot 
where SnapshotMonthID = 202210 
and TripMonthID <= 202210 -- remove last month from the comparison
group by SnapshotMonthID ,  TripMonthID 
) b 
JOIN 
(
select	SnapshotMonthID,  
		TripMonthID, 
		sum(TxnCount)  TxnCount ,
		Sum(ExpectedAmount) ExpectedAmount
from edw_trips.dbo.Fact_UnifiedTransaction_SummarySnapshot 
where SnapshotMonthID = 202211 
and TripMonthID <= 202210 -- remove last month from the comparison
group by SnapshotMonthID ,  TripMonthID 
) a ON a.TripMonthID = b.TripMonthID							
ORDER by a.TripMonthID DESC 


SELECT COUNT(1) RC FROM stage.UnifiedTransaction_PrevRun WHERE TripDayID/100 = 202210  
SELECT COUNT(1) RC FROM stage.UnifiedTransaction_ThisRun WHERE TripDayID/100 = 202210  

--:: Diff examples
SELECT TM.TPTripID, TM.TripDate, TT.CreatedDate TP_Trips_CreatedDate, TT.UpdatedDate TP_Trips_UpdatedDate, TT.LND_UpdateDate LND_LoadDate -- select min(TT.CreatedDate)
--INTO SANDBOX.dbo.Bubble_GoldStandard_202210_Diff
FROM stage.UnifiedTransaction_ThisRun TM
LEFT JOIN stage.UnifiedTransaction_PrevRun PM ON pm.TPTripID = tm.TPTripID
JOIN LND_TBOS.TollPlus.TP_Trips TT ON TM.TPTripID = TT.TPTripID
WHERE tm.TripDayID/100 = 202210 
AND pm.TPTripID IS NULL 
ORDER BY TM.LND_UpdateDate, TM.TripDate

--:: TP_Trips load info
SELECT * FROM LND_TBOS.Utility.ProcessLog WHERE LogSource LIKE '%TP_Trips%' ORDER BY 1 desc
--:: Bubble load info
SELECT * FROM Utility.ProcessLog WHERE LogMessage LIKE '%UnifiedTransaction%' ORDER BY 1 desc

SELECT CONVERT(DATE,tm.LND_UpdateDate) LND_LoadDate, tm.TripDayID/100 TripMonthID, tm.SourceOfEntry, COUNT(1) TxnCount, SUM(tm.ExpectedAmount) ExpectedAmount
FROM stage.UnifiedTransaction_ThisRun TM
LEFT JOIN stage.UnifiedTransaction_PrevRun PM
ON pm.TPTripID = tm.TPTripID
WHERE tm.TripDayID/100 = 202210 
AND pm.TPTripID IS NULL 
GROUP BY CONVERT(DATE,tm.LND_UpdateDate), tm.TripDayID/100, tm.SourceOfEntry
ORDER BY 1

--:: Dup check
SELECT TPTripID, COUNT(1) RC FROM ref.TartTPTrip GROUP BY TPTripID HAVING COUNT(1) > 1
SELECT TPTripID, COUNT(1) RC FROM stage.UnifiedTransaction ut GROUP BY TPTripID HAVING COUNT(1) > 1
SELECT TPTripID, COUNT(1) RC FROM dbo.Fact_UnifiedTransaction ut GROUP BY TPTripID HAVING COUNT(1) > 1

-------Gold Standard-Counts by Mapping--------------
							
select	a.SnapshotMonthID,  
		b.Mapping,
		a.TripMonthID/100 as TransactionYear,
		sum(a.tXNcOUNT)  TxnCount ,
		sum(ExpectedAmount) ExpectedAmount
from	edw_trips.dbo.Fact_UnifiedTransaction_SummarySnapshot a
		join edw_trips.dbo.Dim_OperationsMapping b
			on a.OperationsMappingId = B.OperationsMappingID
where	a.SnapshotMonthID in (202210, 202211)  -- Compare last 2 snapshots
and TripMonthID != 202211 -- remove last month from the comparison
group by a.SnapshotMonthID ,  b.Mapping, a.TripMonthID/100 
order by 2,3 desc


*/


