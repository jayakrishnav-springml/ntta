CREATE PROC [dbo].[Fact_Violation_Load] @IsFullLoad [BIT] AS

/*
IF OBJECT_ID ('dbo.Fact_Violation_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Fact_Violation_Load
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_Violation_Load 1
EXEC Utility.FromLog 'dbo.Fact_Violation', 1
SELECT TOP 100 * FROM dbo.Fact_Violation 
SELECT count_BIG(*) CNT, 'dbo.Fact_Violation' AS TableName FROM dbo.Fact_Violation -- 786922727
SELECT count_BIG(*) CNT, 'LND_TBOS.TollPlus.TP_ViolatedTrips' AS TableName FROM LND_TBOS.TollPlus.TP_ViolatedTrips -- 787045884
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_Violation table. 

@IsFullLoad - 1 means forced Full load, 0 or NULL - incremental load. I the main table is not exists - it goes with full load.

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838  Bhanu/Gouthami  2020-12-31  New!
CHG0038039  Gouthami		2020-01-27	Added DeleteFlag
CHG0038304  Andy			2021-02-04  Changed to Full&Incremental load   -- Set correct Clog number
CHG0038458	Andy			03/30/2021	Save Last Update date in LoadProcessControl after successful run.  fixed CurrentTxnFlag. Added TRY/CATCH
###################################################################################################################
*/
BEGIN
BEGIN TRY
	/*====================================== TESTING =======================================================================*/
	--DECLARE @IsFullLoad BIT = 1 
	/*====================================== TESTING =======================================================================*/

	DECLARE @TableName VARCHAR(100) = 'dbo.Fact_Violation', @StageTableName VARCHAR(100) = 'dbo.Fact_Violation_NEW', @IdentifyingColumns VARCHAR(100) = '[CitationID]'
	DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_Violation_Load', @Log_Start_Date DATETIME2(3) = SYSDATETIME()
	DECLARE @Log_Message VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing
	DECLARE @Last_Updated_Date DATETIME2(3), @sql VARCHAR(MAX), @CreateTableWith VARCHAR(MAX)

	DECLARE @Partition_Ranges VARCHAR(MAX), @FirstPartitionID INT = 200001, @LastPartitionID INT = CAST(CONVERT(VARCHAR(6),DATEADD(DAY,1,EOMONTH(SYSDATETIME(),1)),112) AS INT)

	IF OBJECT_ID(@TableName) IS NULL
					SET @IsFullLoad = 1

	IF @IsFullLoad = 1
	BEGIN
		IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_PartitionDayIDRange_String from ' + CAST(@FirstPartitionID AS VARCHAR(10))+ ' till ' + CAST(@LastPartitionID AS VARCHAR(10))
		EXEC Utility.Get_PartitionDayIDRange_String @FirstPartitionID, @LastPartitionID, @Partition_Ranges OUTPUT
		-- Will use if go to columnstore - not delete this comment!!!!! --  SET @CreateTableWith = '(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
		SET @CreateTableWith = '(CLUSTERED INDEX (' + @IdentifyingColumns + '), DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
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
	-- Load dbo.Fact_Violation
	--============================================================================================================

	SET @sql = '
	IF OBJECT_ID(''' + @StageTableName + ''',''U'') IS NOT NULL                                          DROP TABLE ' + @StageTableName + ';

	CREATE TABLE ' + @StageTableName + ' WITH ' + @CreateTableWith + ' AS
	WITH Main_CTE AS
	(
		SELECT
			ISNULL(CAST(TP.CitationID AS BIGINT), -1) AS CitationID
			, ISNULL(TP.TPTripID, -1) AS TPTripID
			, ISNULL(CAST(CONVERT(VARCHAR(8), TP.ExitTripDateTime, 112) AS INT), -1) AS TripDayID
			, ISNULL(CAST(TP.ExitLaneID AS INT), -1) AS LaneID
			, ISNULL(CAST(TP.ViolatorID AS BIGINT), -1) AS CustomerID                          
			, ISNULL(CAST(TP.CustRefID AS BIGINT), -1) AS CustRefID
			, ISNULL(CAST(TP.VehicleID AS BIGINT), -1) AS VehicleID
			, ISNULL(CAST(TP.AccountAgencyID AS BIGINT), -1) AS AccountAgencyID
			, ISNULL(CAST(TP.TripStatusID AS INT), -1) AS TripStatusID
			, ISNULL(CAST(TP.TripStageID AS INT), -1) AS TripStageID
			, ISNULL(CAST(TP.TransactionTypeID AS SMALLINT), -1) AS TransactionTypeID
			, ISNULL(CAST(TPT.TransactionPostingTypeID AS INT), -1) AS TransactionPostingTypeID
			, ISNULL(CAST(CS.CitationStageID AS INT), -1) AS CitationStageID
			, ISNULL(CAST(TP.PaymentstatusID AS BIGINT), -1) AS PaymentStatusID
			, ISNULL(CAST(CASE WHEN TP.VehicleClass IN (''2'',''3'',''4'',''5'',''6'',''7'',''8'',''11'',''12'',''13'',''14'',''15'',''16'',''17'',''18'') THEN TP.VehicleClass ELSE NULL END AS SMALLINT),-1) AS VehicleClassID               
			, ISNULL(CAST(TP.SourceOfEntry AS TINYINT), 0) AS SourceOfEntry
			, ISNULL(CAST(TP.ExitTripDateTime AS DATETIME2(3)), ''1900-01-01'') AS TripDate
			, ISNULL(CAST(TP.TripStatusDate AS DATETIME2(3)), ''1900-01-01'') AS TripStatusDate
			, ISNULL(CAST(TP.PostedDate AS DATETIME2(3)), ''1900-01-01'') AS PostedDate
			, ISNULL(CAST(TP.WriteOffDate AS DATETIME2(3)), ''1900-01-01'') AS WriteOffDate
			, ISNULL(CAST(TP.IsWriteOff AS BIT), 0) AS WriteOffFlag
			, ISNULL(CAST(CASE WHEN TP.LND_UpdateType = ''D'' THEN 1 ELSE 0 END AS BIT), 0) AS DeleteFlag
			, ISNULL(CAST(TP.TollAmount AS DECIMAL(9,2)), 0) AS TollAmount
			, ISNULL(CAST(TP.FeeAmounts AS DECIMAL(9,2)), 0) AS FeeAmount
			, ISNULL(CAST(TP.OutStandingAmount AS DECIMAL(9,2)), 0) AS OutStandingAmount
			, ISNULL(CAST(TP.NetAmount AS DECIMAL(9,2)), 0) AS NetAmount
			, ISNULL(CAST(TP.PBMTollAmount AS DECIMAL(9,2)), 0) AS PBMTollAmount
			, ISNULL(CAST(TP.AviTollAmount AS DECIMAL(9,2)), 0) AS AVITollAmount
			, ISNULL(CAST(TP.WriteOffAmount AS DECIMAL(9,2)), 0) AS WriteOffAmount
			, ISNULL(CAST(TP.UpdatedDate AS DATETIME2(3)), ''1900-01-01'') AS UpdatedDate
			, ISNULL(CAST(TP.LND_UpdateDate AS datetime2(3)), ''1900-01-01'') AS LND_UpdateDate
			, ISNULL(CAST(''' + CONVERT(VARCHAR(25),@Log_Start_Date,121) + ''' AS datetime2(3)), ''1900-01-01'') AS EDW_UpdateDate
			--:: Drop these columns after MSTR team is OK
			, CAST(TP.ExitTripDateTime AS DATETIME2(3)) AS TransactionDate
		FROM LND_TBOS.TollPlus.TP_ViolatedTrips TP
		LEFT JOIN dbo.Dim_TransactionPostingType TPT ON TPT.TransactionPostingType = TP.TransactionPostingType
		LEFT JOIN dbo.Dim_CitationStage CS ON CS.CitationStageCode = TP.CitationStage
		WHERE 1 = 1 --AND TP.LND_UpdateType <> ''D''
	)
	SELECT
		  CitationID
		, TPTripID
		, TripDayID
		, LaneID
		, CustomerID
		, CustRefID
		, VehicleID
		, AccountAgencyID
		, TripStatusID
		, TripStageID
		, TransactionTypeID
		, TransactionPostingTypeID
		, CitationStageID
		, PaymentStatusID
		, VehicleClassID
		, SourceOfEntry
		, TripDate
		, TripStatusDate
		, PostedDate
		, WriteOffDate
		, WriteOffFlag
		, ISNULL(CAST(CASE WHEN ROW_NUMBER() OVER (PARTITION BY TPTripID ORDER BY DeleteFlag ASC, CitationID DESC) = 1 THEN 1 ELSE 0 END AS BIT), 0) AS CurrentTxnFlag
		, DeleteFlag
		, TollAmount
		, FeeAmount
		, OutStandingAmount
		, NetAmount
		, PBMTollAmount
		, AVITollAmount
		, WriteOffAmount
		, UpdatedDate
		, LND_UpdateDate
		, EDW_UpdateDate
		, TransactionDate
	FROM Main_CTE
	--WHERE RN = 1
	OPTION (LABEL = ''' + @StageTableName + ''');'


	IF @IsFullLoad != 1
	BEGIN
		SET @sql = REPLACE(@sql,'WITH Main_CTE AS','WITH ChangedTPTripIDs_CTE AS
		(
			SELECT TP.CitationID, TP.TPTripID
			FROM LND_TBOS.TollPlus.TP_ViolatedTrips TP
			WHERE TP.LND_UpdateDate > ''' + CONVERT(VARCHAR(25),@Last_Updated_Date,121) + '''
		)
		, ChangedCurrentTxnFlags_CTE AS
		(
			SELECT TP.CitationID
			FROM ' + @TableName + ' TP
			WHERE EXISTS (SELECT 1 FROM ChangedTPTripIDs_CTE AS CTE WHERE TP.TPTripID = CTE.TPTripID AND TP.CitationID != CTE.CitationID) AND CurrentTxnFlag = 1
		)
		, ChangedCitationIDs_CTE AS
		(
			SELECT CitationID
			FROM ChangedTPTripIDs_CTE
			UNION ALL
			SELECT CitationID
			FROM ChangedCurrentTxnFlags_CTE
		)
		, Main_CTE AS')

		SET @sql = REPLACE(@sql,'WHERE 1 = 1','WHERE EXISTS (SELECT 1 FROM ChangedCitationIDs_CTE AS CTE WHERE TP.CitationID = CTE.CitationID)')
                
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
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_005 ON ' + @StageTableName + '(SourceOfEntry)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_006 ON ' + @StageTableName + '(TripStatusID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_007 ON ' + @StageTableName + '(LaneID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_008 ON ' + @StageTableName + '(CitationStageID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_009 ON ' + @StageTableName + '(VehicleClassID)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_050 ON ' + @StageTableName + '(DeleteFlag)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_051 ON ' + @StageTableName + '(WriteOffFlag)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_052 ON ' + @StageTableName + '(CurrentTxnFlag)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_101 ON ' + @StageTableName + '(LND_UpdateDate)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_102 ON ' + @StageTableName + '(UpdatedDate)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_103 ON ' + @StageTableName + '(EDW_UpdateDate)
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
EXEC dbo.Fact_Violation_Load

EXEC Utility.FromLog 'dbo.Fact_Violation', 1
SELECT TOP 100 'dbo.Fact_Violation' TableName, * FROM dbo.Fact_Violation ORDER BY 2

--===============================================================================================================
-- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
--===============================================================================================================
--===============================================================================================================
-- !!! Recently removed columns !!! 
--===============================================================================================================
			--, ISNULL(CAST(TP.IsExcessiveVToll AS BIT), 0) AS ExcessiveVTollFlag
			--, ISNULL(CAST(TP.IsImmediateFlag AS BIT), 0) AS ImmediateFlag


			TESTING:

EXEC dbo.Fact_Violation_Load 1

EXEC Utility.FromLog 'dbo.Fact_Violation', 1

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_Violation', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  -- 2021-02-25 16:48:58.935

EXEC Utility.Set_UpdatedDate 'dbo.Fact_Violation', NULL, '2021-02-25 16:30:00'

EXEC dbo.Fact_Violation_Load 0

EXEC Utility.FromLog 'dbo.Fact_Violation', 3

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_Violation', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  -- 2021-02-25 16:48:58.935



*/

