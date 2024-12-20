CREATE PROC [dbo].[Fact_AdjExpectedAmount_Load] @IsFullLoad [BIT] AS
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_AdjExpectedAmount from dbo.Fact_AdjExpectedAmountDetail tables for Board Reporting. This proc is 
called from dbo.Fact_AdjExpectedAmountDetail_Load and it requires dbo.Fact_AdjExpectedAmountDetail_NEW for incr load.
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040744	Shankar		2022-03-21	New!
CHG0041406  Shekhar     2022-08-22  New Column ClassAdjustmentFlag
									This column will allow us to identify the type of adjustment for a transaction.
									As of today, the downstream programs are using this column to identify if a
									transcation has a Class adjustment or now. The value of 1 in this column means
									the transcation has a class related adjustment. 
CHG0042644	Shankar		2023-03-01	Incremental load cleanup of invalid data in existing table
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_AdjExpectedAmount_Load 1
SELECT * FROM Utility.ProcessLog WHERE LogSource = 'dbo.Fact_AdjExpectedAmount_Load' ORDER BY 1 DESC
SELECT TOP 100 'dbo.Fact_AdjExpectedAmount' Table_Name, * FROM dbo.Fact_AdjExpectedAmount ORDER BY LND_UpdateDate DESC
###################################################################################################################
*/
BEGIN
BEGIN TRY

	/*=========================================== TESTING ========================================================*/
	--DECLARE @IsFullLoad BIT = 1 
	/*=========================================== TESTING ========================================================*/

	DECLARE @TableName VARCHAR(100) = 'dbo.Fact_AdjExpectedAmount', @StageTableName VARCHAR(100) = 'dbo.Fact_AdjExpectedAmount_NEW', @IdentifyingColumns VARCHAR(100) = '[TPTripID]'
	DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_AdjExpectedAmount_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
	DECLARE @Log_Message VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing
	DECLARE @Last_Updated_Date DATETIME2(3), @sql VARCHAR(MAX), @CreateTableWith VARCHAR(MAX)
	DECLARE @FirstDateToLoad VARCHAR(30) = '2019-01-01', @LastDateToLoad VARCHAR(30) = SYSDATETIME()
	DECLARE @Partition_Ranges VARCHAR(MAX), @FirstPartitionID INT = 201901, @LastPartitionID INT = CAST(CONVERT(VARCHAR(6),DATEADD(DAY,1,EOMONTH(SYSDATETIME(),1)),112) AS INT)
	
	IF OBJECT_ID(@TableName) IS NULL OR OBJECT_ID('dbo.Fact_AdjExpectedAmountDetail_NEW') IS NULL
		SET @IsFullLoad = 1

	IF @IsFullLoad = 1
	BEGIN
		IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_PartitionDayIDRange_String from ' + CAST(@FirstPartitionID AS VARCHAR(10))+ ' till ' + CAST(@LastPartitionID AS VARCHAR(10))
		EXEC Utility.Get_PartitionDayIDRange_String @FirstPartitionID, @LastPartitionID, @Partition_Ranges OUTPUT
		SET @CreateTableWith = '(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
		--SET @CreateTableWith = '(CLUSTERED INDEX (' + @IdentifyingColumns + '), DISTRIBUTION = HASH(TPTripID), PARTITION (DayID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'
		SET @Log_Message = 'Started full load'
		IF @Trace_Flag = 1 PRINT @Log_Message
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
	END
	ELSE
	BEGIN
			SET @CreateTableWith = '(CLUSTERED INDEX (' + @IdentifyingColumns + '), DISTRIBUTION = HASH(TPTripID))'
			SET @Log_Message = 'Started incremental load' 
			IF @Trace_Flag = 1 PRINT @Log_Message
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
	END

	--=============================================================================================================
	-- Load dbo.Fact_AdjExpectedAmount
	--============================================================================================================
	SET @sql = '
	IF OBJECT_ID(''' + @StageTableName + ''',''U'') IS NOT NULL		DROP TABLE ' + @StageTableName + ';
	CREATE TABLE ' + @StageTableName + ' WITH ' + @CreateTableWith + ' AS
	SELECT TPTripID
		 , TripDayID
		 , CAST(MAX(CASE when TollAdjustmentID = 1 then 1 else 0 END) AS smallint) ClassAdjustmentFlag --We are only interested ClassAdjustments, which has a TollAdjustmentID of 1 	
		 , CAST(SUM(Amount) AS DECIMAL(19,2)) AdjustedExpectedAmount
		 , CAST(SUM(CASE WHEN CurrentTxnFlag = 1 AND SourceName = ''Adjustment_LineItems'' THEN Amount END) AS decimal(19,2)) TripWithAdjustedAmount
		 , CAST(SUM(CASE WHEN SourceName = ''Adjustment_LineItems'' THEN Amount END) AS decimal(19,2)) AllAdjustedAmount
		 , CAST(SUM(CASE WHEN CustTripID IS NOT NULL AND SourceName = ''Adjustment_LineItems'' THEN Amount END) AS decimal(19,2)) AllCustTripAdjustedAmount 
		 , CAST(SUM(CASE WHEN CitationID IS NOT NULL AND SourceName = ''Adjustment_LineItems'' THEN Amount END) AS decimal(19,2)) AllViolatedTripAdjustedAmount
		 , CAST(SUM(CASE WHEN SourceName = ''BOS_IOP_OutboundTransactions-Paid'' THEN Amount ELSE 0 END) AS decimal(19,2)) IOP_OutboundPaidAmount -- default must be 0, not null
		 , CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
	FROM dbo.Fact_AdjExpectedAmountDetail' + CASE WHEN ISNULL(@IsFullLoad,1) = 0 THEN '_NEW' ELSE '' END + ' -- <== Following on the tail of Full or Incremental Load of dbo.Fact_AdjExpectedAmountDetail    
	GROUP BY TPTripID, TripDayID
	OPTION (LABEL = ''' + @StageTableName + ''');'

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
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_003 ON ' + @StageTableName + '(ClassAdjustmentFlag)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_004 ON ' + @StageTableName + '(AdjustedExpectedAmount)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_005 ON ' + @StageTableName + '(TripWithAdjustedAmount)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_006 ON ' + @StageTableName + '(AllAdjustedAmount)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_007 ON ' + @StageTableName + '(AllCustTripAdjustedAmount)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_008 ON ' + @StageTableName + '(AllViolatedTripAdjustedAmount)
		CREATE STATISTICS STATS_' + REPLACE(@TableName,'.','_') + '_009 ON ' + @StageTableName + '(IOP_OutboundPaidAmount)
		'
		IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
		EXEC (@sql)

		-- Table swap!
		EXEC Utility.TableSwap @StageTableName, @TableName

		SET @Log_Message = 'Completed full load'
	END
	ELSE
	BEGIN  
		DELETE dbo.Fact_AdjExpectedAmount WHERE TpTripID IN (SELECT TpTripID FROM Temp.Fact_AdjExpectedAmountDetail_DEL)
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Deleted TpTripID rows not qualified for full load from dbo.Fact_AdjExpectedAmount using Temp.Fact_AdjExpectedAmountDetail_DEL', 'I', NULL, -1

		IF @Trace_Flag = 1 PRINT 'Calling: Utility.ManagePartitions_DateID'
		EXEC Utility.ManagePartitions_DateID @TableName, 'DayID:Month'

		IF @Trace_Flag = 1 PRINT 'Calling: Utility.PartitionSwitch_Range'
		EXEC Utility.PartitionSwitch_Range @StageTableName, @TableName, @IdentifyingColumns, Null

		SET @sql = 'UPDATE STATISTICS  ' + @TableName
		IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
		EXEC (@sql)

		SET @Log_Message = 'Completed Incremental load'
	END
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

	IF @Trace_Flag = 1 
	BEGIN
		PRINT @Log_Message
		SELECT TOP 100 'dbo.Fact_AdjExpectedAmount' TableName, * FROM dbo.Fact_AdjExpectedAmount ORDER BY EDW_UpdateDate DESC
		EXEC Utility.FromLog @TableName, @Log_Start_Date
	END

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
EXEC dbo.Fact_AdjExpectedAmount_Load 1
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE 'dbo.Fact_AdjExpectedAmount%' ORDER BY 1 DESC  
SELECT TOP 100 'dbo.Fact_AdjExpectedAmount' TableName, * FROM dbo.Fact_AdjExpectedAmount ORDER BY 2
SELECT EDW_UpdateDate, COUNT_BIG(1) RC FROM dbo.Fact_AdjExpectedAmount GROUP BY EDW_UpdateDate ORDER BY 1 DESC

SELECT COUNT_BIG(1) RC FROM dbo.Fact_AdjExpectedAmount_NEW 
SELECT COUNT_BIG(1) RC FROM dbo.Fact_AdjExpectedAmount 

--:: Testing
EXEC dbo.Fact_AdjExpectedAmount_Load 1

EXEC Utility.FromLog 'dbo.Fact_AdjExpectedAmount', 1

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_AdjExpectedAmount', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  

EXEC Utility.Set_UpdatedDate 'dbo.Fact_AdjExpectedAmount', NULL, '2022-03-04'

EXEC dbo.Fact_AdjExpectedAmount_Load 0

EXEC Utility.FromLog 'dbo.Fact_AdjExpectedAmount', 3

DECLARE @Last_Updated_Date DATETIME2(3)
EXEC Utility.Get_UpdatedDate 'dbo.Fact_AdjExpectedAmount', @Last_Updated_Date OUTPUT
PRINT @Last_Updated_Date  

--===============================================================================================================
-- !!! Dynamic SQL!!! 
--===============================================================================================================
IF OBJECT_ID('dbo.Fact_AdjExpectedAmount_NEW','U') IS NOT NULL		DROP TABLE dbo.Fact_AdjExpectedAmount_NEW;
CREATE TABLE dbo.Fact_AdjExpectedAmount_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(TPTripID), PARTITION (TripDayID RANGE RIGHT FOR VALUES (20190101,20190201,20190301,20190401,20190501,20190601,20190701,20190801,20190901,20191001,20191101,20191201,20200101,20200201,20200301,20200401,20200501,20200601,20200701,20200801,20200901,20201001,20201101,20201201,20210101,20210201,20210301,20210401,20210501,20210601,20210701,20210801,20210901,20211001,20211101,20211201,20220101,20220201,20220301,20220401,20220501,20220601,20220701,20220801,20220901,20221001))) AS
SELECT TPTripID
		, TripDayID
		, CAST(MAX(CASE when TollAdjustmentID = 1 then 1 else 0 END) AS smallint) ClassAdjustmentFlag --We are only interested ClassAdjustments, which has a TollAdjustmentID of 1 	
		, CAST(SUM(Amount) AS DECIMAL(19,2)) AdjustedExpectedAmount
		, CAST(SUM(CASE WHEN CurrentTxnFlag = 1 AND SourceName = 'Adjustment_LineItems' THEN Amount END) AS decimal(19,2)) TripWithAdjustedAmount
		, CAST(SUM(CASE WHEN SourceName = 'Adjustment_LineItems' THEN Amount END) AS decimal(19,2)) AllAdjustedAmount
		, CAST(SUM(CASE WHEN CustTripID IS NOT NULL AND SourceName = 'Adjustment_LineItems' THEN Amount END) AS decimal(19,2)) AllCustTripAdjustedAmount 
		, CAST(SUM(CASE WHEN CitationID IS NOT NULL AND SourceName = 'Adjustment_LineItems' THEN Amount END) AS decimal(19,2)) AllViolatedTripAdjustedAmount
		, CAST(SUM(CASE WHEN SourceName = 'BOS_IOP_OutboundTransactions-Paid' THEN Amount ELSE 0 END) AS decimal(19,2)) IOP_OutboundPaidAmount -- default must be 0, not null
		, CAST(SYSDATETIME() AS DATETIME2(3)) EDW_UpdateDate
FROM dbo.Fact_AdjExpectedAmountDetail -- <== Following on the tail of Full or Incremental Load of dbo.Fact_AdjExpectedAmountDetail 
GROUP BY TPTripID, TripDayID
OPTION (LABEL = 'dbo.Fact_AdjExpectedAmount_NEW');


*/	
