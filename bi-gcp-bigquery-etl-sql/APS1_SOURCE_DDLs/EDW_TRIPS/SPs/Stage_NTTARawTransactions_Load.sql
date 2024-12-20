CREATE PROC [Stage].[NTTARawTransactions_Load] @IsFullLoad [BIT] AS
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load Stage.NTTARawTransactions table to optmize dbo.Fact_UnifiedTransaction load as part of Bubble ETL Process 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040744	Shankar		2022-03-21	New!
CHG0041141	Shankar		2022-06-30	New columns added
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Stage.NTTARawTransactions_Load 1
SELECT * FROM Utility.ProcessLog WHERE LogSource = 'Stage.NTTARawTransactions_Load' ORDER BY 1 DESC
SELECT TOP 100 'Stage.NTTARawTransactions' Table_Name, * FROM Stage.NTTARawTransactions ORDER BY LND_UpdateDate DESC
###################################################################################################################
*/

BEGIN
BEGIN TRY
	
	/*=========================================== TESTING ========================================================*/
	--DECLARE @IsFullLoad BIT = 1 
	/*=========================================== TESTING ========================================================*/

	DECLARE @TableName VARCHAR(100) = 'Stage.NTTARawTransactions', @StageTableName VARCHAR(100) = 'Stage.NTTARawTransactions_NEW', @IdentifyingColumns VARCHAR(100) = '[TPTripID]'
	DECLARE @Log_Source VARCHAR(100) = 'Stage.NTTARawTransactions_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
	DECLARE @Log_Message VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing
	DECLARE @Last_Updated_Date DATETIME2(3), @sql VARCHAR(MAX), @CreateTableWith VARCHAR(MAX)
	DECLARE @FirstDateToLoad VARCHAR(10) = '2021-01-01', @LastDateToLoad VARCHAR(10) = SYSDATETIME()
	DECLARE @Partition_Ranges VARCHAR(MAX), @FirstPartitionID INT = 202101, @LastPartitionID INT = CAST(CONVERT(VARCHAR(6),DATEADD(DAY,1,EOMONTH(SYSDATETIME(),1)),112) AS INT)
	
	IF OBJECT_ID(@TableName) IS NULL
		SET @IsFullLoad = 1

	IF @IsFullLoad = 1
	BEGIN
		IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_PartitionDayIDRange_String from ' + CAST(@FirstPartitionID AS VARCHAR(10))+ ' till ' + CAST(@LastPartitionID AS VARCHAR(10))
		EXEC Utility.Get_PartitionDayIDRange_String @FirstPartitionID, @LastPartitionID, @Partition_Ranges OUTPUT
		SET @CreateTableWith = '(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
		--SET @CreateTableWith = '(CLUSTERED INDEX (' + @IdentifyingColumns + '), DISTRIBUTION = HASH(TPTripID), PARTITION (DayID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
		SET @Log_Message = 'Started full load'
	END
	ELSE
	BEGIN
		SET @CreateTableWith = '(CLUSTERED INDEX (' + @IdentifyingColumns + '), DISTRIBUTION = HASH(TPTripID))'
		IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_UpdatedDate for ' + @TableName
		EXEC Utility.Get_UpdatedDate @TableName, @Last_Updated_Date OUTPUT 
		SET @Log_Message = 'Started incremental load from: ' + CONVERT(VARCHAR(25),@Last_Updated_Date,121)
	END

	IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

	--============================================================================================================
	-- Load Stage.NTTARawTransactions
	--============================================================================================================
	
	SET @sql = '
	IF OBJECT_ID(''' + @StageTableName + ''',''U'') IS NOT NULL			DROP TABLE ' + @StageTableName + ';

	CREATE TABLE ' + @StageTableName + ' WITH ' + @CreateTableWith + ' AS
	SELECT 
		TT.TPTripID
		, TT.SourceTripID
		, ISNULL(CAST(CONVERT(VARCHAR(8), TT.ExitTripDateTime, 112) AS INT), -1) AS TripDayID
		, TT.ExitTripDateTime TripDate -- NRaw.Timestamp is TripDateUTC
		, TT.SourceOfEntry
		, NRaw.RecordType
		, NRaw.ViolationSerialNumber
		, NRaw.VesTimestamp -- In UTC. May not be precisely equal to TripDate, but is important in the 5 key join with IPS to find TPTripID
		, CAST(DATEADD(HOUR, CASE WHEN NRaw.VesTimestamp BETWEEN tz.DST_Start_Date_UTC AND tz.DST_End_Date_UTC THEN -5 ELSE -6 END, NRaw.VesTimestamp) AS DATETIME2(3)) AS LocalVesTimestamp
		, TT.ExitLaneID LaneID
		, NRaw.FacilityCode
		, NRaw.PlazaCode
		, NRaw.Lane LaneNumber
		, NRaw.VehicleSpeed
		, NRaw.RevenueVehicleClass
		, NRaw.TagStatus LaneTagStatus
		, NRaw.FareAmount
		, NRaw.LND_UpdateDate
		, CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate
	FROM LND_TBOS.TOLLPLUS.TP_TRIPS TT 
	JOIN LND_TBOS.TranProcessing.NTTARawTransactions NRaw
			ON NRaw.TxnID = TT.SourceTripID AND TT.SourceOfEntry = 1 -- NTTA 
	LEFT JOIN LND_TBOS.Utility.Time_Zone_Offset TZ
			ON YEAR(NRaw.VesTimestamp) = tz.YYYY
	WHERE 1 = 1 
		AND TT.Exit_TollTxnID >= 0
		AND TT.ExitTripDateTime >= ''' + @FirstDateToLoad + '''  
		AND TT.ExitTripDateTime <  ''' + @LastDateToLoad  + '''
		AND TT.LND_UpdateType <> ''D''
		AND NRaw.LND_UpdateType <> ''D''

	OPTION (LABEL = ''' + @StageTableName + ''');'

	IF @IsFullLoad != 1
		SET @sql = REPLACE(@sql,'WHERE 1 = 1','WHERE NRaw.LND_UpdateDate > ''' + CONVERT(VARCHAR(25),@Last_Updated_Date,121) + '''')

	IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql

	EXEC (@sql)

	-- Log 
	IF (SELECT COUNT(1) FROM Stage.NTTARawTransactions_NEW) = 0	
		SET  @Log_Message = 'No data to load into ' + @StageTableName
	ELSE 
		SET  @Log_Message = 'Loaded ' + @StageTableName
			
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
		
	-- Create statistics and swap table
	IF @IsFullLoad = 1
	BEGIN

		SET @sql = '
		CREATE STATISTICS Stats_' + REPLACE(@TableName,'.','_') + '_001 ON ' + @StageTableName + '(TpTripID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_002 ON ' + @StageTableName + '(TripDayID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_003 ON ' + @StageTableName + '(SourceTripID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_004 ON ' + @StageTableName + '(TripDate)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_005 ON ' + @StageTableName + '(ViolationSerialNumber)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_006 ON ' + @StageTableName + '(VesTimestamp)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_007 ON ' + @StageTableName + '(VehicleSpeed)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_008 ON ' + @StageTableName + '(RevenueVehicleClass)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_009 ON ' + @StageTableName + '(LaneTagStatus)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_010 ON ' + @StageTableName + '(FacilityCode)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_011 ON ' + @StageTableName + '(PlazaCode)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_012 ON ' + @StageTableName + '(LaneNumber)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_013 ON ' + @StageTableName + '(LaneID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_014 ON ' + @StageTableName + '(FareAmount)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_501 ON ' + @StageTableName + '(LND_UpdateDate)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_502 ON ' + @StageTableName + '(EDW_UpdateDate)
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
EXEC Stage.NTTARawTransactions_Load 0
SELECT * FROM Utility.ProcessLog WHERE LogSource = 'Stage.NTTARawTransactions_Load' ORDER BY 1 DESC
SELECT * FROM Utility.LoadProcessControl WHERE TableName LIKE '%NTTARawTransactions%'
SELECT TOP 100 'Stage.NTTARawTransactions' TableName, * FROM Stage.NTTARawTransactions ORDER BY 2

SELECT TOP 10 * FROM LND_TBOS.TranProcessing.NTTARawTransactions WHERE LND_UpdateDate > '5/22/2022'  

SELECT LND_UpdateDate, COUNT(*) RC FROM LND_TBOS.TranProcessing.NTTARawTransactions WHERE LND_UpdateDate > '5/22/2022' GROUP BY LND_UpdateDate ORDER BY LND_UpdateDate DESC
SELECT COUNT(*) RC, MAX(EDW_UpdateDate) FROM Stage.NTTARawTransactions_NEW
SELECT COUNT(*) RC, MAX(EDW_UpdateDate) FROM Stage.NTTARawTransactions

--:: Testing
EXEC Stage.NTTARawTransactions_Load 1

EXEC Utility.FromLog 'Stage.NTTARawTransactions', 1

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'Stage.NTTARawTransactions', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  

EXEC Utility.Set_UpdatedDate 'Stage.NTTARawTransactions', NULL, '2022-05-22'

EXEC Stage.NTTARawTransactions_Load 0

EXEC Utility.FromLog 'Stage.NTTARawTransactions', 3

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'Stage.NTTARawTransactions', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  

--===============================================================================================================
-- !!! Dynamic SQL!!!
--===============================================================================================================

--:: Full Load
IF OBJECT_ID('Stage.NTTARawTransactions_NEW','U') IS NOT NULL			DROP TABLE Stage.NTTARawTransactions_NEW;

CREATE TABLE Stage.NTTARawTransactions_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (20190101,20190201,20190301,20190401,20190501,20190601,20190701,20190801,20190901,20191001,20191101,20191201,20200101,20200201,20200301,20200401,20200501,20200601,20200701,20200801,20200901,20201001,20201101,20201201,20210101,20210201,20210301,20210401,20210501,20210601,20210701,20210801,20210901,20211001,20211101,20211201,20220101,20220201,20220301,20220401,20220501,20220601,20220701,20220801))) AS
SELECT 
	TT.TPTripID
	, TT.SourceTripID
	, ISNULL(CAST(CONVERT(VARCHAR(8), TT.ExitTripDateTime, 112) AS INT), -1) AS TripDayID
	, TT.ExitTripDateTime TripDate -- NRaw.Timestamp is TripDateUTC
	, TT.SourceOfEntry
	, NRaw.RecordType
	, NRaw.ViolationSerialNumber
	, NRaw.VesTimestamp -- In UTC. May not be precisely equal to TripDate, but is important in the 5 key join with IPS to find TPTripID
	, CAST(DATEADD(HOUR, CASE WHEN NRaw.VesTimestamp BETWEEN tz.DST_Start_Date_UTC AND tz.DST_End_Date_UTC THEN -5 ELSE -6 END, NRaw.VesTimestamp) AS DATETIME2(3)) AS LocalVesTimestamp
	, TT.ExitLaneID LaneID
	, NRaw.FacilityCode
	, NRaw.PlazaCode
	, NRaw.Lane LaneNumber
	, NRaw.VehicleSpeed
	, NRaw.RevenueVehicleClass
	, NRaw.TagStatus LaneTagStatus
	, NRaw.FareAmount
	, NRaw.LND_UpdateDate
	, CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate
FROM LND_TBOS.TOLLPLUS.TP_TRIPS TT 
JOIN LND_TBOS.TranProcessing.NTTARawTransactions NRaw
		ON NRaw.TxnID = TT.SourceTripID AND TT.SourceOfEntry = 1 -- NTTA 
LEFT JOIN LND_TBOS.Utility.Time_Zone_Offset TZ
		ON YEAR(NRaw.VesTimestamp) = tz.YYYY
WHERE 1 = 1 
	AND TT.Exit_TollTxnID >= 0
	AND TT.ExitTripDateTime >= '2021-01-01'  
	AND TT.ExitTripDateTime <  '2022-06-15'
	AND TT.LND_UpdateType <> 'D'
	AND NRaw.LND_UpdateType <> 'D'

OPTION (LABEL = 'Stage.NTTARawTransactions_NEW');

CREATE STATISTICS Stats_Stage_NTTARawTransactions_001 ON Stage.NTTARawTransactions_NEW(TpTripID)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_002 ON Stage.NTTARawTransactions_NEW(TripDayID)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_003 ON Stage.NTTARawTransactions_NEW(SourceTripID)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_004 ON Stage.NTTARawTransactions_NEW(TripDate)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_005 ON Stage.NTTARawTransactions_NEW(ViolationSerialNumber)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_006 ON Stage.NTTARawTransactions_NEW(VesTimestamp)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_007 ON Stage.NTTARawTransactions_NEW(VehicleSpeed)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_008 ON Stage.NTTARawTransactions_NEW(RevenueVehicleClass)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_009 ON Stage.NTTARawTransactions_NEW(LaneTagStatus)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_010 ON Stage.NTTARawTransactions_NEW(FacilityCode)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_011 ON Stage.NTTARawTransactions_NEW(PlazaCode)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_012 ON Stage.NTTARawTransactions_NEW(LaneNumber)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_013 ON Stage.NTTARawTransactions_NEW(LaneID)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_014 ON Stage.NTTARawTransactions_NEW(FareAmount)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_501 ON Stage.NTTARawTransactions_NEW(LND_UpdateDate)
CREATE STATISTICS STATS_Stage_NTTARawTransactions_502 ON Stage.NTTARawTransactions_NEW(EDW_UpdateDate)

--:: Incremental Load

IF OBJECT_ID('Stage.NTTARawTransactions_NEW','U') IS NOT NULL			DROP TABLE Stage.NTTARawTransactions_NEW;

CREATE TABLE Stage.NTTARawTransactions_NEW WITH (CLUSTERED INDEX ([TPTripID]), DISTRIBUTION = HASH(TPTripID)) AS
SELECT 
	TT.TPTripID
	, TT.SourceTripID
	, ISNULL(CAST(CONVERT(VARCHAR(8), TT.ExitTripDateTime, 112) AS INT), -1) AS TripDayID
	, TT.ExitTripDateTime TripDate -- NRaw.Timestamp is TripDateUTC
	, TT.SourceOfEntry
	, NRaw.RecordType
	, NRaw.ViolationSerialNumber
	, NRaw.VesTimestamp -- In UTC. May not be precisely equal to TripDate, but is important in the 5 key join with IPS to find TPTripID
	, CAST(DATEADD(HOUR, CASE WHEN NRaw.VesTimestamp BETWEEN tz.DST_Start_Date_UTC AND tz.DST_End_Date_UTC THEN -5 ELSE -6 END, NRaw.VesTimestamp) AS DATETIME2(3)) AS LocalVesTimestamp
	, TT.ExitLaneID LaneID
	, NRaw.FacilityCode
	, NRaw.PlazaCode
	, NRaw.Lane LaneNumber
	, NRaw.VehicleSpeed
	, NRaw.RevenueVehicleClass
	, NRaw.TagStatus LaneTagStatus
	, NRaw.FareAmount
	, NRaw.LND_UpdateDate
	, CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate
FROM LND_TBOS.TOLLPLUS.TP_TRIPS TT 
JOIN LND_TBOS.TranProcessing.NTTARawTransactions NRaw
		ON NRaw.TxnID = TT.SourceTripID AND TT.SourceOfEntry = 1 -- NTTA 
LEFT JOIN LND_TBOS.Utility.Time_Zone_Offset TZ
		ON YEAR(NRaw.VesTimestamp) = tz.YYYY
WHERE NRaw.LND_UpdateDate > '2022-03-03 00:00:00.000' 
	AND TT.Exit_TollTxnID >= 0
	AND TT.ExitTripDateTime >= '2022-01-01'  
	AND TT.ExitTripDateTime <  '2022-01-02'
	AND TT.LND_UpdateType <> 'D'
	AND NRaw.LND_UpdateType <> 'D'
OPTION (LABEL = 'Stage.NTTARawTransactions_NEW');

*/	
