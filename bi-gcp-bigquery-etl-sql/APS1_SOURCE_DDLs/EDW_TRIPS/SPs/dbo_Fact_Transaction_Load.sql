CREATE PROC [dbo].[Fact_Transaction_Load] @IsFullLoad [BIT] AS

/*
IF OBJECT_ID ('dbo.Fact_Transaction_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Fact_Transaction_Load
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_Transaction_Load 1

EXEC Utility.FromLog 'dbo.Fact_Transaction', 1
SELECT top 100 * FROM LND_TBOS.TranProcessing.NttaRawTransactions
SELECT top 100 
	TPTripID, TripDayID, LaneID, VehicleID, TagAgencyID, VehicleClassID, TagVehicleClassID, PaymentStatusID, TripStageID, TripStatusID, TripIdentMethodID, 
	TransactionPostingTypeID, ReasonCodeID, SourceTripID, LinkID, IPSTransactionID, SourceOfEntry, RecordType, RecordNumber, VehicleSpeed, Disposition, TripWith, 
	TripDate, TripStatusDate, PostedDate, NonRevenueFlag, DeleteFlag, TollAmount, FeeAmount, ReceivedTollAmount, OutStandingAmount, PBMTollAmount, AVITollAmount, 
	UpdatedDate, LND_UpdateDate, EDW_UpdateDate
FROM dbo.Fact_Transaction
SELECT top 100 * FROM LND_TBOS.TOLLPLUS.TP_TRIPS

SELECT count_BIG(*) CNT, 'LND_TBOS.TOLLPLUS.TP_TRIPS' AS TableName FROM LND_TBOS.TOLLPLUS.TP_TRIPS -- 
																							 17,791,763
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_Transaction table. 

@IsFullLoad - 1 means forced Full load, 0 or NULL - incremental load. I the main table is not exists - it goes with full load.

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038319 	Andy		2021-03-08	New!
CHG0038458	Andy		03/30/2021	Save Last Update date in LoadProcessControl after successful run. Added TRY/CATCH
CHG0038754	Shankar		04/27/2021	Fixed duplicates caused by join to Dim_Vehicle table
###################################################################################################################
*/
BEGIN
BEGIN TRY

	/*====================================== TESTING =======================================================================*/
	--DECLARE @IsFullLoad BIT = 1 
	/*====================================== TESTING =======================================================================*/

	DECLARE @TableName VARCHAR(100) = 'dbo.Fact_Transaction', @StageTableName VARCHAR(100) = 'dbo.Fact_Transaction_NEW', @IdentifyingColumns VARCHAR(100) = '[TPTripID]'
	DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_Transaction_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
	DECLARE @Log_Message VARCHAR(1000), @Trace_Flag BIT = 1 -- Testing
	DECLARE @Last_Updated_Date DATETIME2(3), @sql VARCHAR(MAX), @CreateTableWith VARCHAR(MAX)
	DECLARE @LastDateToLoad VARCHAR(10) = CONVERT(VARCHAR(10),DATEADD(DAY,1,EOMONTH(SYSDATETIME())),121)
	DECLARE @Partition_Ranges VARCHAR(MAX), @FirstPartitionID INT = 201701, @LastPartitionID INT = CAST(CONVERT(VARCHAR(6),DATEADD(DAY,1,EOMONTH(SYSDATETIME(),1)),112) AS INT)
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
	-- Load dbo.Fact_Transaction
	--============================================================================================================

	SET @sql = '
	IF OBJECT_ID(''' + @StageTableName + ''',''U'') IS NOT NULL			DROP TABLE ' + @StageTableName + ';

	CREATE TABLE ' + @StageTableName + ' WITH ' + @CreateTableWith + ' AS
	WITH Main_CTE AS
	(
	SELECT
		ISNULL(TP.TPTripID, -1) AS TPTripID
		, ISNULL(CAST(CONVERT(VARCHAR(8), TP.ExitTripDateTime, 112) AS INT), -1) AS TripDayID
		, ISNULL(CAST(TP.ExitLaneID AS INT), -1) AS LaneID
		, ISNULL(CAST(TP.TripStageID AS INT), -1) AS TripStageID
		, ISNULL(CAST(TP.TripStatusID AS INT), -1) AS TripStatusID
		, ISNULL(CAST(TP.PaymentStatusID AS BIGINT), -1) AS PaymentStatusID
		, ISNULL(CAST(ISNULL(att.SourceTripId, TP.SourceTripID) AS BIGINT), -1) AS SourceTripID
		, ISNULL(CAST(TP.LinkID AS BIGINT), -1) AS LinkID
		, ISNULL(CAST(COALESCE(TP.VehicleID, V.VehicleID) AS BIGINT), -1) AS VehicleID 
		, ISNULL(CAST(TP.TagAgencyID AS INT), -1) AS TagAgencyID			-- Not always could be found in VehicleTagID - sometimes TagAgencyID > -1 and VehicleTagID = -1
		, ISNULL(CAST(PT.TransactionPostingTypeID AS INT), -1) AS TransactionPostingTypeID
		, ISNULL(CAST(NULLIF(TP.IPSTransactionID,0) AS BIGINT), -1) AS IPSTransactionID
		, ISNULL(CAST(RC.ReasonCodeID AS INT), -1) AS ReasonCodeID
		, ISNULL(CAST(CASE WHEN TP.VehicleClass IN (''2'',''3'',''4'',''5'',''6'',''7'',''8'',''11'',''12'',''13'',''14'',''15'',''16'',''17'',''18'') THEN TP.VehicleClass ELSE NULL END AS SMALLINT),-1) AS VehicleClassID
		, ISNULL(CAST(CASE WHEN TP.TagVehicleClass IN (''2'',''3'',''4'',''5'',''6'',''7'',''8'',''11'',''12'',''13'',''14'',''15'',''16'',''17'',''18'') THEN TP.TagVehicleClass ELSE NULL END AS SMALLINT),-1) AS TagVehicleClassID
		, ISNULL(CAST(TI.TripIdentMethodID AS SMALLINT),-1) AS TripIdentMethodID
		, ISNULL(CAST(TP.SourceOfEntry AS TINYINT), 0) AS SourceOfEntry
		, ISNULL(CAST(COALESCE(RT.RecordType,TRaw.RecordType) AS VARCHAR(4)),'''') AS RecordType
		, ISNULL(CAST(COALESCE(RT.RecordNumber,TRaw.SubscriberUniqueTransactionID) AS BIGINT), 0) AS RecordNumber
		, ISNULL(CAST(COALESCE(RT.VehicleSpeed,TRaw.Speed) AS INT), 0) AS VehicleSpeed
		, ISNULL(CAST(TP.Disposition AS VARCHAR(2)),''-1'') AS Disposition
		, ISNULL(CAST(TP.TripWith AS VARCHAR(2)),''-1'') AS TripWith
		, ISNULL(CAST(TP.ExitTripDateTime AS DATETIME2(3)), ''1900-01-01'') AS TripDate
		, ISNULL(CAST(TP.TripStatusDate AS DATE), ''1900-01-01'') AS TripStatusDate
		, ISNULL(CAST(TP.PostedDate AS DATE), ''1900-01-01'') AS PostedDate
		, ISNULL(CAST(TP.IsNonRevenue AS BIT), 0) AS NonRevenueFlag
		, ISNULL(CAST(CASE WHEN TP.LND_UpdateType = ''D'' THEN 1 ELSE 0 END AS BIT), 0) AS DeleteFlag
		, ISNULL(CAST(TP.TollAmount AS DECIMAL(9,2)), 0) AS TollAmount
		, ISNULL(CAST(TP.FeeAmounts AS DECIMAL(9,2)), 0) AS FeeAmount
		, ISNULL(CAST(TP.ReceivedTollAmount AS DECIMAL(9,2)), 0) AS ReceivedTollAmount
		, ISNULL(CAST(TP.OutStandingAmount AS DECIMAL(9,2)), 0) AS OutStandingAmount
		, ISNULL(CAST(TP.PBMTollAmount AS DECIMAL(9,2)), 0) AS PBMTollAmount
		, ISNULL(CAST(TP.AVITollAmount AS DECIMAL(9,2)), 0) AS AVITollAmount
		, ISNULL(CAST(TP.UpdatedDate AS DATETIME2(3)), ''1900-01-01'') AS UpdatedDate
		, ISNULL(CAST(TP.LND_UpdateDate AS datetime2(3)), ''1900-01-01'') AS LND_UpdateDate
		, ISNULL(CAST(''' + CONVERT(VARCHAR(25),@Log_Start_Date,121) + ''' AS datetime2(3)), ''1900-01-01'') AS EDW_UpdateDate
		, ROW_NUMBER() OVER (PARTITION BY TP.TpTripID ORDER BY V.VehicleStartDate DESC) RN
	FROM LND_TBOS.TOLLPLUS.TP_TRIPS TP
	LEFT JOIN LND_TBOS.TranProcessing.NttaRawTransactions RT ON TP.SourceTripID = RT.TxnID AND tp.SourceOfEntry = 1
	LEFT JOIN LND_TBOS.tsa.TSATripAttributes att ON tp.SourceTripID = att.TTpTripID AND tp.SourceOfEntry = 3
	LEFT JOIN LND_TBOS.TranProcessing.TSARawTransactions TRaw ON att.SourceTripId = TRaw.TxnID
	LEFT JOIN dbo.Dim_TransactionPostingType PT ON PT.TransactionPostingType = TP.TransactionPostingType
	LEFT JOIN dbo.Dim_TripIdentMethod TI ON TI.TripIdentMethod = TP.TripIdentMethod
	LEFT JOIN dbo.Dim_ReasonCode RC ON RC.ReasonCode = RTRIM(LTRIM(TP.ReasonCode))
	LEFT JOIN dbo.Dim_Vehicle V ON V.LicensePlateNumber = TP.VehicleNumber AND V.LicensePlateState = TP.VehicleState AND TP.ExitTripDateTime BETWEEN V.VehicleStartDate AND V.VehicleEndDate
	WHERE 1 = 1 AND TP.ExitTripDateTime < ''' + @LastDateToLoad + '''
	)
	SELECT
		  TPTripID
		, TripDayID
		, LaneID
		, TripStageID
		, TripStatusID
		, PaymentStatusID
		, SourceTripID
		, LinkID
		, VehicleID
		, TagAgencyID
		, TransactionPostingTypeID
		, IPSTransactionID
		, ReasonCodeID
		, VehicleClassID
		, TagVehicleClassID
		, TripIdentMethodID
		, SourceOfEntry
		, RecordType
		, RecordNumber
		, VehicleSpeed
		, Disposition
		, TripWith
		, TripDate
		, TripStatusDate
		, PostedDate
		, NonRevenueFlag
		, DeleteFlag
		, TollAmount
		, FeeAmount
		, ReceivedTollAmount
		, OutStandingAmount
		, PBMTollAmount
		, AVITollAmount
		, UpdatedDate
		, LND_UpdateDate
		, EDW_UpdateDate
	FROM Main_CTE
	WHERE RN = 1
	OPTION (LABEL = ''' + @StageTableName + ''');'

	IF @IsFullLoad != 1
		SET @sql = REPLACE(@sql,'WHERE 1 = 1','WHERE TP.LND_UpdateDate > ''' + CONVERT(VARCHAR(25),@Last_Updated_Date,121) + '''')

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
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_003 ON ' + @StageTableName + '(PaymentStatusID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_004 ON ' + @StageTableName + '(TripStageID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_005 ON ' + @StageTableName + '(TripStatusID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_006 ON ' + @StageTableName + '(IPSTransactionID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_007 ON ' + @StageTableName + '(SourceOfEntry)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_008 ON ' + @StageTableName + '(TransactionPostingTypeID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_009 ON ' + @StageTableName + '(TripIdentMethodID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_010 ON ' + @StageTableName + '(SourceTripID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_101 ON ' + @StageTableName + '(NonRevenueFlag)
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
EXEC dbo.Fact_Transaction_Load

EXEC Utility.FromLog 'dbo.Fact_Transaction', 1
SELECT TOP 100 'dbo.Fact_Transaction' TableName, * FROM dbo.Fact_Transaction ORDER BY 2

--===============================================================================================================
-- !!! Dynamic SQL!!!
--===============================================================================================================

IF OBJECT_ID('dbo.Fact_Transaction_NEW','U') IS NOT NULL			DROP TABLE dbo.Fact_Transaction_NEW;

CREATE TABLE dbo.Fact_Transaction_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (20170101,20170201,20170301,20170401,20170501,20170601,20170701,20170801,20170901,20171001,20171101,20171201,20180101,20180201,20180301,20180401,20180501,20180601,20180701,20180801,20180901,20181001,20181101,20181201,20190101,20190201,20190301,20190401,20190501,20190601,20190701,20190801,20190901,20191001,20191101,20191201,20200101,20200201,20200301,20200401,20200501,20200601,20200701,20200801,20200901,20201001,20201101,20201201,20210101,20210201,20210301,20210401,20210501,20210601))) AS
WITH Main_CTE AS
(
SELECT
	ISNULL(TP.TPTripID, -1) AS TPTripID
	, ISNULL(CAST(CONVERT(VARCHAR(8), TP.ExitTripDateTime, 112) AS INT), -1) AS TripDayID
	, ISNULL(CAST(TP.ExitLaneID AS INT), -1) AS LaneID
	, ISNULL(CAST(TP.TripStageID AS INT), -1) AS TripStageID
	, ISNULL(CAST(TP.TripStatusID AS INT), -1) AS TripStatusID
	, ISNULL(CAST(TP.PaymentStatusID AS BIGINT), -1) AS PaymentStatusID
	, ISNULL(CAST(ISNULL(att.SourceTripId, TP.SourceTripID) AS BIGINT), -1) AS SourceTripID
	, ISNULL(CAST(TP.LinkID AS BIGINT), -1) AS LinkID
	, ISNULL(CAST(COALESCE(TP.VehicleID, V.VehicleID) AS BIGINT), -1) AS VehicleID 
	, ISNULL(CAST(TP.TagAgencyID AS INT), -1) AS TagAgencyID			-- Not always could be found in VehicleTagID - sometimes TagAgencyID > -1 and VehicleTagID = -1
	, ISNULL(CAST(PT.TransactionPostingTypeID AS INT), -1) AS TransactionPostingTypeID
	, ISNULL(CAST(NULLIF(TP.IPSTransactionID,0) AS BIGINT), -1) AS IPSTransactionID
	, ISNULL(CAST(RC.ReasonCodeID AS INT), -1) AS ReasonCodeID
	, ISNULL(CAST(CASE WHEN TP.VehicleClass IN ('2','3','4','5','6','7','8','11','12','13','14','15','16','17','18') THEN TP.VehicleClass ELSE NULL END AS SMALLINT),-1) AS VehicleClassID
	, ISNULL(CAST(CASE WHEN TP.TagVehicleClass IN ('2','3','4','5','6','7','8','11','12','13','14','15','16','17','18') THEN TP.TagVehicleClass ELSE NULL END AS SMALLINT),-1) AS TagVehicleClassID
	, ISNULL(CAST(TI.TripIdentMethodID AS SMALLINT),-1) AS TripIdentMethodID
	, ISNULL(CAST(TP.SourceOfEntry AS TINYINT), 0) AS SourceOfEntry
	, ISNULL(CAST(COALESCE(RT.RecordType,TRaw.RecordType) AS VARCHAR(4)),'') AS RecordType
	, ISNULL(CAST(COALESCE(RT.RecordNumber,TRaw.SubscriberUniqueTransactionID) AS BIGINT), 0) AS RecordNumber
	, ISNULL(CAST(COALESCE(RT.VehicleSpeed,TRaw.Speed) AS INT), 0) AS VehicleSpeed
	, ISNULL(CAST(TP.Disposition AS VARCHAR(2)),'-1') AS Disposition
	, ISNULL(CAST(TP.TripWith AS VARCHAR(2)),'-1') AS TripWith
	, ISNULL(CAST(TP.ExitTripDateTime AS DATETIME2(3)), '1900-01-01') AS TripDate
	, ISNULL(CAST(TP.TripStatusDate AS DATE), '1900-01-01') AS TripStatusDate
	, ISNULL(CAST(TP.PostedDate AS DATE), '1900-01-01') AS PostedDate
	, ISNULL(CAST(TP.IsNonRevenue AS BIT), 0) AS NonRevenueFlag
	, ISNULL(CAST(CASE WHEN TP.LND_UpdateType = 'D' THEN 1 ELSE 0 END AS BIT), 0) AS DeleteFlag
	, ISNULL(CAST(TP.TollAmount AS DECIMAL(9,2)), 0) AS TollAmount
	, ISNULL(CAST(TP.FeeAmounts AS DECIMAL(9,2)), 0) AS FeeAmount
	, ISNULL(CAST(TP.ReceivedTollAmount AS DECIMAL(9,2)), 0) AS ReceivedTollAmount
	, ISNULL(CAST(TP.OutStandingAmount AS DECIMAL(9,2)), 0) AS OutStandingAmount
	, ISNULL(CAST(TP.PBMTollAmount AS DECIMAL(9,2)), 0) AS PBMTollAmount
	, ISNULL(CAST(TP.AVITollAmount AS DECIMAL(9,2)), 0) AS AVITollAmount
	, ISNULL(CAST(TP.UpdatedDate AS DATETIME2(3)), '1900-01-01') AS UpdatedDate
	, ISNULL(CAST(TP.LND_UpdateDate AS datetime2(3)), '1900-01-01') AS LND_UpdateDate
	, ISNULL(CAST('2021-04-27 16:34:39.990' AS datetime2(3)), '1900-01-01') AS EDW_UpdateDate
	, ROW_NUMBER() OVER (PARTITION BY TP.TpTripID ORDER BY V.VehicleStartDate DESC) RN
FROM LND_TBOS.TOLLPLUS.TP_TRIPS TP
LEFT JOIN LND_TBOS.TranProcessing.NttaRawTransactions RT ON TP.SourceTripID = RT.TxnID AND tp.SourceOfEntry = 1
LEFT JOIN LND_TBOS.tsa.TSATripAttributes att ON tp.SourceTripID = att.TTpTripID AND tp.SourceOfEntry = 3
LEFT JOIN LND_TBOS.TranProcessing.TSARawTransactions TRaw ON att.SourceTripId = TRaw.TxnID
LEFT JOIN dbo.Dim_TransactionPostingType PT ON PT.TransactionPostingType = TP.TransactionPostingType
LEFT JOIN dbo.Dim_TripIdentMethod TI ON TI.TripIdentMethod = TP.TripIdentMethod
LEFT JOIN dbo.Dim_ReasonCode RC ON RC.ReasonCode = RTRIM(LTRIM(TP.ReasonCode))
LEFT JOIN dbo.Dim_Vehicle V ON V.LicensePlateNumber = TP.VehicleNumber AND V.LicensePlateState = TP.VehicleState AND TP.ExitTripDateTime BETWEEN V.VehicleStartDate AND V.VehicleEndDate
WHERE 1 = 1 AND TP.ExitTripDateTime < '2021-05-01'
)
SELECT
		TPTripID
	, TripDayID
	, LaneID
	, TripStageID
	, TripStatusID
	, PaymentStatusID
	, SourceTripID
	, LinkID
	, VehicleID
	, TagAgencyID
	, TransactionPostingTypeID
	, IPSTransactionID
	, ReasonCodeID
	, VehicleClassID
	, TagVehicleClassID
	, TripIdentMethodID
	, SourceOfEntry
	, RecordType
	, RecordNumber
	, VehicleSpeed
	, Disposition
	, TripWith
	, TripDate
	, TripStatusDate
	, PostedDate
	, NonRevenueFlag
	, DeleteFlag
	, TollAmount
	, FeeAmount
	, ReceivedTollAmount
	, OutStandingAmount
	, PBMTollAmount
	, AVITollAmount
	, UpdatedDate
	, LND_UpdateDate
	, EDW_UpdateDate
FROM Main_CTE
WHERE RN = 1
OPTION (LABEL = 'dbo.Fact_Transaction_NEW');


--===============================================================================================================
-- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
--===============================================================================================================

SELECT TripDayID/100 AS MONTHID , COUNT_BIG(1) FROM dbo.Fact_Transaction				-- 1480156608
GROUP BY TripDayID/100
ORDER BY MONTHID

SELECT Disposition , COUNT_BIG(1) FROM dbo.Fact_Transaction				-- 1480156608
GROUP BY Disposition
ORDER BY Disposition


SELECT TOP 10 *
FROM LND_TBOS.TOLLPLUS.TP_TRIPS tp WITH (NOLOCK)
INNER JOIN LND_TBOS.tsa.TSATripAttributes att WITH (NOLOCK)
		ON tp.SOURCETRIPID = att.TTpTripID
INNER JOIN LND_TBOS.TranProcessing.TSARawTransactions TRaw WITH (NOLOCK)
		ON att.SourceTripId = TRaw.TxnID
WHERE tp.SourceOfEntry = 3

IF OBJECT_ID('dbo.Dim_TripIdentMethod') IS NOT NULL DROP TABLE dbo.Dim_TripIdentMethod;
CREATE TABLE dbo.Dim_TripIdentMethod WITH (HEAP, DISTRIBUTION = REPLICATE) AS
SELECT * FROM (
SELECT CAST(1 AS SMALLINT) AS TripIdentMethodID, 'AVI' AS TripIdentMethodCode, 'AviToll' AS TripIdentMethod UNION ALL
SELECT CAST(2 AS SMALLINT) AS TripIdentMethodID, 'VToll' AS TripIdentMethodCode, 'VideoToll' AS TripIdentMethod UNION ALL
SELECT CAST(-1 AS SMALLINT) AS TripIdentMethodID, 'Null' AS TripIdentMethodCode, 'Unknown' AS TripIdentMethod) A
 
Testing:

EXEC dbo.Fact_Transaction_Load 1

EXEC Utility.FromLog 'dbo.Fact_Transaction', 1

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_Transaction', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  -- 2021-02-25 16:52:43.985

SELECT  LND_UpdateDate, COUNT_BIG(1) Cnt
FROM dbo.Fact_Transaction
GROUP BY LND_UpdateDate
ORDER BY LND_UpdateDate DESC

EXEC Utility.Set_UpdatedDate 'dbo.Fact_Transaction', NULL, '2021-02-25 16:00:00'

-- 2021-02-25 16:00:00.000
EXEC dbo.Fact_Transaction_Load 0

EXEC Utility.FromLog 'dbo.Fact_Transaction', 1

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_Transaction', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  -- 2021-02-25 16:52:43.985

*/
