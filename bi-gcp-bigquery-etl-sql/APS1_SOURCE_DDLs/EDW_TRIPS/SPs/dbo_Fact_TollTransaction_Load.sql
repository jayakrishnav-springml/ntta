CREATE PROC [dbo].[Fact_TollTransaction_Load] @IsFullLoad [BIT] AS

/*
IF OBJECT_ID ('dbo.Fact_TollTransaction_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Fact_TollTransaction_Load
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_TollTransaction_Load 0

EXEC Utility.FromLog 'dbo.Fact_TollTransaction', 3

SELECT TOP 100 * FROM dbo.Fact_TollTransaction 
SELECT COUNT_BIG(1) FROM dbo.Fact_TollTransaction				-- 1480156608
SELECT COUNT_BIG(1) FROM LND_TBOS.TollPlus.TP_CustomerTrips	-- 1479637789
SELECT COUNT_BIG(1) FROM LND_TBOS.Stage.TP_CustomerTrips	-- 1479637789
																						
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_TollTransaction table. 

@IsFullLoad - 1 means forced Full load, 0 or NULL - incremental load. I the main table is not exists - it goes with full load.

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Bhanu	2020-01-04	New!
			Arun Krishna 2021-01-22 
			1. Added APPROVEDSTATUSID = 466 as Per MSTR Team Request, which will give only Approved Adjustments.

CHG0038040  Arun Krishna 2021-01-27 -- Added Delete Flag and removed Current Txn Flag
CHG0038319 	Andy		2021-03-08	--	Chagned to Full&Incremental load, removed dups by Tags, refactoried columns
CHG0038458	Andy		03/30/2021	Save Last Update date in LoadProcessControl after successful run.  fixed CurrentTxnFlag. Added TRY/CATCH
###################################################################################################################
*/
BEGIN
BEGIN TRY

	/*====================================== TESTING =======================================================================*/
	--DECLARE @IsFullLoad BIT = 1 
	/*====================================== TESTING =======================================================================*/

	DECLARE @TableName VARCHAR(100) = 'dbo.Fact_TollTransaction', @StageTableName VARCHAR(100) = 'dbo.Fact_TollTransaction_NEW', @IdentifyingColumns VARCHAR(100) = '[CustTripID]'
	DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_TollTransaction_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
	DECLARE @Log_Message VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing
	DECLARE @LastDateToLoad VARCHAR(10) = CONVERT(VARCHAR(10),DATEADD(DAY,1,EOMONTH(SYSDATETIME())),121)
	DECLARE @Last_Updated_Date DATETIME2(3), @sql VARCHAR(MAX), @CreateTableWith VARCHAR(MAX)
	DECLARE @Partition_Ranges VARCHAR(MAX), @FirstPartitionID INT = 201901, @LastPartitionID INT = CAST(CONVERT(VARCHAR(6),DATEADD(DAY,1,EOMONTH(SYSDATETIME(),1)),112) AS INT)

	IF OBJECT_ID(@TableName) IS NULL
		SET @IsFullLoad = 1

	IF @IsFullLoad = 1
	BEGIN
		IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_PartitionDayIDRange_String from ' + CAST(@FirstPartitionID AS VARCHAR(10))+ ' till ' + CAST(@LastPartitionID AS VARCHAR(10))
		EXEC Utility.Get_PartitionDayIDRange_String @FirstPartitionID, @LastPartitionID, @Partition_Ranges OUTPUT
		SET @CreateTableWith = '(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
		SET @Log_Message = 'Started Full load'
	END
	ELSE
	BEGIN
		SET @CreateTableWith = '(CLUSTERED INDEX (' + @IdentifyingColumns + '), DISTRIBUTION = HASH(TPTripID))'
		IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_UpdatedDate for ' + @TableName
		EXEC Utility.Get_UpdatedDate @TableName, @Last_Updated_Date OUTPUT 
		SET @Log_Message = 'Started Incremental load from: ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)
	END

	IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

	--=============================================================================================================
	-- Load dbo.Fact_TollTransaction
	--============================================================================================================

	SET @sql = '
	IF OBJECT_ID(''' + @StageTableName + ''',''U'') IS NOT NULL			DROP TABLE ' + @StageTableName + ';

	CREATE TABLE ' + @StageTableName + ' WITH ' + @CreateTableWith + ' AS 
	WITH Main_CTE AS
	(
	SELECT
		ISNULL(CAST(TP.CustTripID AS BIGINT), -1) AS CustTripID
		, ISNULL(TP.TPTripID, -1) AS TPTripID
		, ISNULL(CAST(CONVERT(VARCHAR(8), TP.ExitTripDateTime, 112) AS INT), -1) AS TripDayID
		, ISNULL(CAST(TP.ExitLaneID AS INT), -1) AS LaneID
		, ISNULL(CAST(TP.PaymentStatusID AS INT), -1) AS PaymentStatusID
		, ISNULL(CAST(TP.TripStageID AS INT), -1) AS TripStageID
		, ISNULL(CAST(TP.TripStatusID AS INT), -1) AS TripStatusID
		, ISNULL(CAST(TP.CustomerID AS BIGINT), -1) AS CustomerID
		, ISNULL(CAST(COALESCE(DCT.CustTagID ,CT.CustTagID) AS BIGINT), -1) AS CustTagID
		, ISNULL(CAST(DCT.VehicleTagID AS BIGINT), -1) AS VehicleTagID
		, ISNULL(CAST(COALESCE(TP.VehicleID, DCT.VehicleID, V.VehicleID) AS BIGINT), -1) AS VehicleID 
		, ISNULL(CAST(TPT.TransactionPostingTypeID AS INT), -1) AS TransactionPostingTypeID
		, ISNULL(CAST(CASE WHEN TP.VehicleClass IN (''2'',''3'',''4'',''5'',''6'',''7'',''8'',''11'',''12'',''13'',''14'',''15'',''16'',''17'',''18'') THEN TP.VehicleClass ELSE NULL END AS SMALLINT),-1) AS VehicleClassID
		, ISNULL(CAST(TI.TripIdentMethodID AS INT),-1) AS TripIdentMethodID
		, ISNULL(CAST(TP.SourceOfEntry AS TINYINT), 0) AS SourceOfEntry
		, ISNULL(CAST(TP.ExitTripDateTime AS DATETIME2(3)), ''1900-01-01'') AS TripDate
		, ISNULL(CAST(TP.PostedDate AS DATETIME2(3)), ''1900-01-01'') AS PostedDate
		, ISNULL(CAST(TP.TripStatusDate AS DATETIME2(3)), ''1900-01-01'') AS TripStatusDate
		, ISNULL(CAST(Adj.AdjustmentDate AS DATETIME2(3)), ''1900-01-01'') AS AdjustedDate
		, ISNULL(CAST(CASE WHEN TP.LND_UpdateType = ''D'' THEN 1 ELSE 0 END AS BIT), 0) AS DeleteFlag
		, ISNULL(CAST(TP.TollAmount AS DECIMAL(9,2)), 0) AS TollAmount
		, ISNULL(CAST(TP.FeeAmounts AS DECIMAL(9,2)), 0) AS FeeAmount
		, ISNULL(CAST(TP.DiscountsAmount AS DECIMAL(9,2)), 0) AS DiscountAmount
		, ISNULL(CAST(TP.NetAmount AS DECIMAL(9,2)), 0) AS NetAmount
		, ISNULL(CAST(TP.Rewards_DiscountAmount AS DECIMAL(9,2)), 0) AS RewardDiscountAmount
		, ISNULL(CAST(TP.OutstandingAmount AS DECIMAL(9,2)), 0) AS OutstandingAmount
		, ISNULL(CAST(TP.PBMTollAmount AS DECIMAL(9,2)), 0) AS PBMTollAmount
		, ISNULL(CAST(TP.AVITollAmount AS DECIMAL(9,2)), 0) AS AVITollAmount
		, ISNULL(CAST(Adj.AdjustedTolls AS DECIMAL(9,2)), 0) AS AdjustedTollAmount
		, ISNULL(CAST(TP.UpdatedDate AS DATETIME2(3)), ''1900-01-01'') AS UpdatedDate
		, ISNULL(CAST(TP.LND_UpdateDate AS datetime2(3)), ''1900-01-01'') AS LND_UpdateDate
		, ISNULL(CAST(''' + CONVERT(VARCHAR(25),@Log_Start_Date,121) + ''' AS datetime2(3)), ''1900-01-01'') AS EDW_UpdateDate
		--:: Drop these columns after MSTR team is OK
		, ISNULL(CAST(TP.ExitTripDateTime AS DATETIME2(3)), ''1900-01-01'') AS TxnDatetime
		, ISNULL(CAST(TP.FeeAmounts AS DECIMAL(9,2)), 0) AS FeeAmounts
		, ISNULL(CAST(Adj.AdjustedTolls AS DECIMAL(9,2)), 0) AS AdjustedTolls
		, CAST(TP.TripIdentMethod AS VARCHAR(10))		 AS TripIdentMethod
		, CAST(TP.Rewards_DiscountAmount AS DECIMAL(9,2)) AS RewardsDiscountAmount
		, ISNULL(CAST(TP.DiscountsAmount AS DECIMAL(9,2)), 0) AS DiscountsAmount
		, ROW_NUMBER() OVER (PARTITION BY TP.CustTripID ORDER BY CASE WHEN DCT.VehicleID = TP.VehicleID THEN 1 ELSE 2 END ASC, DCT.TagStatusOrder ASC, DCT.TagStartDate DESC, CT.TagStatusStartDate DESC) RN 
	FROM LND_TBOS.TollPlus.TP_CustomerTrips TP
	LEFT JOIN dbo.Dim_TransactionPostingType TPT ON TPT.TransactionPostingType = TP.TransactionPostingType
	LEFT JOIN dbo.Dim_TripIdentMethod TI ON TI.TripIdentMethod = TP.TripIdentMethod
	LEFT JOIN dbo.Dim_Vehicle V ON V.LicensePlateNumber = TP.VehicleNumber AND V.LicensePlateState = TP.VehicleState AND TP.ExitTripDateTime BETWEEN V.VehicleStartDate AND V.VehicleEndDate
	LEFT JOIN dbo.Dim_CustomerTag CT ON CT.TagID = TP.TagRefID AND CT.TagAgency = TP.TagAgency AND CT.CustomerID = TP.CustomerID --AND CT.TagStatusStartDate <= TP.ExitTripDateTime
	LEFT JOIN (
				SELECT CustomerID, CustTagID, VehicleTagID, TagID,TagAgency,VehicleID,TagStartDate,TagEndDate, CASE WHEN TagStatus IN (''Assigned'',''Transferred'') THEN 1 ELSE 2 END AS TagStatusOrder
				FROM dbo.Dim_VehicleTag
				) AS DCT ON DCT.TagID = TP.TagRefID AND DCT.TagAgency = TP.TagAgency AND DCT.CustomerID = TP.CustomerID AND TP.ExitTripDateTime BETWEEN DCT.TagStartDate AND DCT.TagEndDate
	LEFT JOIN
		(
			SELECT CTRT.LinkID AS CustTripID, MAX(ADJ.ApprovedStatusDate) AS AdjustmentDate, SUM(ADJ.AMOUNT * CASE WHEN DRCRFLAG = ''D'' THEN -1 ELSE 1 END) AS AdjustedTolls
			FROM 	LND_TBOS.Finance.Adjustment_LineItems CTRT  
					INNER JOIN  LND_TBOS.Finance.Adjustments ADJ  ON ADJ.AdjustmentID = CTRT.AdjustmentID AND CTRT.LinkSourceName = ''TOLLPLUS.TP_CUSTOMERTRIPS'' AND ADJ.APPROVEDSTATUSID = 466
			GROUP BY CTRT.LinkID
		) Adj ON Adj.CustTripID = TP.CustTripID
	WHERE 1 = 1 AND TP.ExitTripDateTime < ''' + @LastDateToLoad + ''' --AND TP.LND_UpdateType <> ''D''
	)
	SELECT
		  CustTripID
		, TPTripID
		, TripDayID
		, LaneID
		, CustomerID
		, VehicleID
		, CustTagID
		, VehicleTagID
		, VehicleClassID
		, PaymentStatusID
		, TripStageID
		, TripStatusID
		, TripIdentMethodID
		, TransactionPostingTypeID
		, SourceOfEntry
		, TripDate
		, PostedDate
		, TripStatusDate
		, AdjustedDate
		, ISNULL(CAST(CASE WHEN ROW_NUMBER() OVER (PARTITION BY TPTripID ORDER BY DeleteFlag ASC, CustTripID DESC) = 1 THEN 1 ELSE 0 END AS BIT), 0) AS CurrentTxnFlag
		, DeleteFlag
		, TollAmount
		, FeeAmount
		, DiscountAmount
		, NetAmount
		, RewardDiscountAmount
		, OutstandingAmount
		, PBMTollAmount
		, AVITollAmount
		, AdjustedTollAmount
		, UpdatedDate
		, LND_UpdateDate
		, EDW_UpdateDate
		, TxnDatetime
		, FeeAmounts
		, AdjustedTolls
		, TripIdentMethod
		, RewardsDiscountAmount
		, DiscountsAmount
	FROM Main_CTE
	WHERE RN = 1
	OPTION (LABEL = ''' + @StageTableName + ''');'

	IF @IsFullLoad != 1
	BEGIN
		SET @sql = REPLACE(@sql,'WITH Main_CTE AS','WITH ChangedTPTripIDs_CTE AS
		(
			SELECT ' + @IdentifyingColumns + ', TPTripID
			FROM LND_TBOS.TollPlus.TP_CustomerTrips 
			WHERE LND_UpdateDate > ''' + CONVERT(VARCHAR(25),@Last_Updated_Date,121) + '''
		)
		, ChangedCurrentTxnFlags_CTE AS
		(
			SELECT ' + @IdentifyingColumns + '
			FROM ' + @TableName + ' TP
			WHERE EXISTS (SELECT 1 FROM ChangedTPTripIDs_CTE AS CTE WHERE TP.TPTripID = CTE.TPTripID AND TP.CustTripID != CTE.CustTripID) AND CurrentTxnFlag = 1
		)
		, ChangedCustTripIDs_CTE AS
		(
			SELECT ' + @IdentifyingColumns + '
			FROM ChangedTPTripIDs_CTE
			UNION ALL
			SELECT ' + @IdentifyingColumns + '
			FROM ChangedCurrentTxnFlags_CTE
		)
		, Main_CTE AS')

		SET @sql = REPLACE(@sql,'WHERE 1 = 1','WHERE EXISTS (SELECT 1 FROM ChangedCustTripIDs_CTE AS CTE WHERE TP.CustTripID = CTE.CustTripID)')
	
	END

	IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql

	EXEC (@sql)
	-- Log 
	SET  @Log_Message = 'Loaded ' + @StageTableName
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, @sql
		
	-- Create statistics and swap table
	IF @IsFullLoad = 1
	BEGIN

		SET @sql = '
		CREATE STATISTICS Stats_' + REPLACE(@TableName,'.','_') + '_001 ON ' + @StageTableName + '(TpTripID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_002 ON ' + @StageTableName + '(TripDayID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_003 ON ' + @StageTableName + '(CustomerID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_004 ON ' + @StageTableName + '(TripStageID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_005 ON ' + @StageTableName + '(CustTripID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_006 ON ' + @StageTableName + '(TripStatusID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_007 ON ' + @StageTableName + '(TransactionPostingTypeID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_008 ON ' + @StageTableName + '(SourceOfEntry)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_009 ON ' + @StageTableName + '(TripIdentMethodID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_100 ON ' + @StageTableName + '(CurrentTxnFlag)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_300 ON ' + @StageTableName + '(DeleteFlag)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_501 ON ' + @StageTableName + '(LND_UpdateDate)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_502 ON ' + @StageTableName + '(UpdatedDate)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_503 ON ' + @StageTableName + '(EDW_UpdateDate)
		'

		IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
		EXEC (@sql)
		-- Table swap!
		EXEC Utility.TableSwap @StageTableName, @TableName

		SET @Log_Message = 'Completed full load'
	END
	ELSE
	BEGIN
		IF @Trace_Flag = 1 PRINT 'Calling: Utility.ManagePartitions_DateID'
		EXEC Utility.ManagePartitions_DateID @TableName, 'DayID:Month'

		IF @Trace_Flag = 1 PRINT 'Calling: Utility.PartitionSwitch_Range'
		EXEC Utility.PartitionSwitch_Range @StageTableName, @TableName, @IdentifyingColumns, Null

		SET @sql = 'UPDATE STATISTICS  ' + @TableName
		IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
		EXEC (@sql)

		SET @Log_Message = 'Completed Incremental load from ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)
	END

	SET @Last_Updated_Date = NULL
	EXEC Utility.Set_UpdatedDate @TableName, @TableName, @Last_Updated_Date OUTPUT -- So we going to manually set Updated date to be sure it didn't cach any error before that
	SET @Log_Message = @Log_Message + '. Set Last Update date as ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)

	IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

	IF @Trace_Flag = 1 EXEC Utility.FromLog @TableName, @Log_Start_Date
END	TRY
	
BEGIN CATCH
	
	DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
	EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
	EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
	THROW;  -- Rethrow the error!
	
END CATCH;

END

/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
EXEC dbo.Fact_TollTransaction_Load

EXEC Utility.FromLog 'dbo.Fact_TollTransaction', 1
SELECT TOP 100 'dbo.Fact_TollTransaction' TableName, * FROM dbo.Fact_TollTransaction ORDER BY 2

--===============================================================================================================
-- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
--===============================================================================================================
SELECT TripDayID/100 AS MONTHID , COUNT_BIG(1) FROM dbo.Fact_TollTransaction				-- 1480156608
GROUP BY TripDayID/100
ORDER BY MONTHID

SELECT TripIdentMethod , COUNT_BIG(1) FROM dbo.Fact_TollTransaction				-- 1480156608
GROUP BY TripIdentMethod
ORDER BY TripIdentMethod

SELECT ISNULL(CAST(CASE WHEN ISNUMERIC(TP.VehicleClass) = 1 THEN TP.VehicleClass ELSE NULL END AS SMALLINT),-1) AS VehicleClass, COUNT_BIG(1) AS cnt
FROM LND_TBOS.TOLLPLUS.TP_CustomerTrips TP
GROUP BY ISNULL(CAST(CASE WHEN ISNUMERIC(TP.VehicleClass) = 1 THEN TP.VehicleClass ELSE NULL END AS SMALLINT),-1)
ORDER BY VehicleClass

--===============================================================================================================
-- !!! Recently removed columns !!! 
--===============================================================================================================
		--, ISNULL(CAST(TP.Exit_TollTxnID AS BIGINT), -1) AS TollTxnID							-- Do we need? 
		--, ISNULL(CAST(TP.Disposition AS INT), -1) AS Disposition
		--, ISNULL(CAST(TP.TransactionTypeID AS tinyint), -1) AS TransactionTypeID
		--, ISNULL(CAST(TP.TTxn_ID AS BIGINT), -1) AS TtxnID										-- Do we need?
		--, ISNULL(CAST(TP.AccountAgencyID AS BIGINT), -1) AS AccountAgencyID
		--, ISNULL(CAST(TP.IsExcessiveVToll AS BIT), -1) AS ExcessiveVTollFlag
		--, ISNULL(CAST(TP.IsROVWaiting AS BIT), -1) AS ROVWaitingFlag


TESTING:

EXEC dbo.Fact_TollTransaction_Load 1

EXEC Utility.FromLog 'dbo.Fact_TollTransaction', 1

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_TollTransaction', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  -- 2021-02-25 16:57:12.841

SELECT  LND_UpdateDate, COUNT_BIG(1) Cnt
FROM dbo.Fact_TollTransaction
GROUP BY LND_UpdateDate
ORDER BY LND_UpdateDate DESC

EXEC Utility.Set_UpdatedDate 'dbo.Fact_TollTransaction', NULL, '2021-02-25 16:00:00'
DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_TollTransaction', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  -- 2021-02-25 16:00:00.000

-- 2021-02-25 16:00:00.000
EXEC dbo.Fact_TollTransaction_Load 0

EXEC Utility.FromLog 'dbo.Fact_TollTransaction', 1

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_TollTransaction', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  -- 2021-02-25 16:57:12.841

*/

