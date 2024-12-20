CREATE PROC [dbo].[Fact_InvoiceAgingSnapshot_Load] @Load_Start_Date [DATE] AS 

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_InvoiceAgingSnapshot table by snapshotdate 
If table does not exist, creates table; otherwise load to stage table and switch partitions
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Gouthami, Andy	2020-11-02	New!
CHG0038039	Gouthami, Andy  2021-01-27  1. Created a new utility SP for Partition Switch as the citations were not 
										   updating when there are any changes in the source.
										2. Added Delete Flag
CHG0038304  Gouthami	    2021-02-26	1. Added WriteOffFlag, WriteOffAmount, WriteOffDate, FNFeesOutstandingAmount and 
										   SNFeesOutstandingAmount columns
										2. Removed group by for Fact_InvoiceDetail, and Fact_Violation
										3. Removed some columns which are not used by MSTR
CHG0040511  Gouthami		2022-02-25	Removed the columns(TotalTransactions,FNFeeDate,SNFeedate,TotalTxn) that are not used by MSTR.										

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------

Declare @Load_Start_Date [DATE] = CAST(GETDATE() AS DATE)
Exec dbo.Fact_InvoiceAgingSnapshot_Load  @Load_Start_Date 

EXEC Utility.FromLog 'dbo.Fact_InvoiceDetail', 1
SELECT COUNT_BIG(1) AS CNT FROM Fact_InvoiceAgingSnapshot  -- 117 100 991
SELECT 'dbo.Fact_InvoiceAgingSnapshot' TableName, * FROM dbo.Fact_InvoiceAgingSnapshot ORDER BY 2 DESC 
SELECT SnapshotDate,COUNT(*) FROM dbo.Fact_InvoiceAgingSnapshot GROUP BY SnapshotDate

###################################################################################################################
*/

BEGIN 	
	--Debug
	--DECLARE @Load_Start_Date [DATE] = CAST(GETDATE() AS DATE)	

	DECLARE @Main_Table_Name VARCHAR(100) = 'dbo.Fact_InvoiceAgingSnapshot'
	DECLARE @StageTableName VARCHAR(100) = 'dbo.Fact_InvoiceAgingSnapshot_NEW'
	DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_InvoiceAgingSnapshot_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
	DECLARE @Log_Message VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing
	DECLARE @sql1 VARCHAR(MAX)
	DECLARE @sql2 VARCHAR(MAX)
	DECLARE @sqlresult VARCHAR(MAX)
	DECLARE @sql VARCHAR(MAX)

	DECLARE @PartitionDate DATE = CASE WHEN DAY(@Load_Start_Date)=1  THEN DATEADD(DAY,-1,CONVERT(DATE,DATEADD(DAY,1,EOMONTH(@Load_Start_Date,-1)))) 
								  ELSE CAST(DATEADD(DAY,-1,@Load_Start_Date) AS DATE) END 

	DECLARE @PartitionMonthID INT = CAST(CONVERT(VARCHAR(6),@PartitionDate,112) AS INT)

	SET @Log_Message = 'Started load for partition ' + CAST(@PartitionDate AS VARCHAR(10))
	IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

	--=============================================================================================================
	-- Load dbo.Fact_InvoiceAging         
	--=============================================================================================================
	
	DECLARE @Partition_Ranges VARCHAR(MAX), @LastPartitionID INT = CAST(CONVERT(VARCHAR(6),DATEADD(DAY,1,EOMONTH(@Log_Start_Date,1)),112) AS INT)
	IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_PartitionMonthIDRange_String from 202001 till ' + CAST(@LastPartitionID AS VARCHAR(10))
	EXEC Utility.Get_PartitionMonthIDRange_String 202001, @LastPartitionID, @Partition_Ranges OUTPUT
	
	IF OBJECT_ID(@Main_Table_Name) IS NULL
		SET @StageTableName = @Main_Table_Name

	SET @sql1 = '
	SELECT  CAST(''' + CONVERT(VARCHAR(10),@PartitionDate, 121) + ''' AS DATE) AS SnapshotDate
		 , ISNULL(CAST(' + CAST(@PartitionMonthID AS VARCHAR(6)) + ' AS INT),0) AS SnapshotMonthID
		 , ISNULL(CitationId, 0) AS CitationID
		 , CAST(InvDet.CustomerID AS BIGINT) AS CustomerID
		 , CAST(InvDet.AgeStageID AS INT) AS AgeStageID
		 , -1 as CitationStageID
		 , ISNULL(CAST(InvDet.LaneID AS INT), 0) AS LaneID
		 , ISNULL(CAST(TPTripID AS BIGINT), 0) AS TPTripID
		 , CAST(InvDet.InvoiceNumber AS BIGINT) AS InvoiceNumber
		 , ISNULL(CAST(InvDet.CurrentInvFlag AS BIT), 0) AS CurrentInvoiceFlag
		 , ISNULL(CAST(InvDet.WriteOffFlag AS BIT), 0) AS WriteOffFlag
		 , ISNULL(InvDet.DeleteFlag ,0) AS DeleteFlag
		 , CAST(InvDet.TxnDate AS date) AS TransactionDate
		 , CAST(InvDet.ZCInvoiceDate AS DATE) AS InvoiceDate
		 , CAST(InvDet.PostedDate AS Date) AS PostedDate
		 , CAST(InvDet.FNFeesDate AS DATE) AS FirstNoticeFeeDate
		 , CAST(InvDet.SNFeesDate AS DATE) AS SecondNoticeFeeDate
		 , CAST(InvDet.WriteOffDate AS DATE) AS  WriteOffDate
		 , CAST(InvDet.Tolls AS DECIMAL(19,2)) AS TollsDue
		 , CAST(InvDet.FNFees AS DECIMAL(38,6)) AS FirstNoticeFees
		 , CAST(InvDet.SNFees AS DECIMAL(38,6)) AS SecondNoticeFees
		 , CAST(InvDet.OutstandingAmount AS DECIMAL(19,2)) AS OutstandingAmount
		 , CAST(InvDet.FNFeesOutstandingAmount AS DECIMAL(38,6)) AS FNFeesOutstandingAmount
		 , CAST(InvDet.SNFeesOutstandingAmount AS DECIMAL(38,6)) AS SNFeesOutstandingAmount		
		 , CAST(InvDet.WriteOffAmount AS DECIMAL(19,2)) AS  WriteOffAmount		 	 		 
		 
		   ---- Drop columns after MSTR team confirmation
		 , CAST(InvDet.TxnDate AS date) AS TxnDate
		 , ISNULL(CAST(SYSDATETIME() AS DATETIME2(3)),''1900-01-01'') EDW_UpdateDate
	FROM  dbo.Fact_InvoiceDetail InvDet 
	WHERE (InvDet.OutstandingAmount > 0 OR InvDet.FNFeesOutstandingAmount > 0 OR InvDet.SNFeesOutstandingAmount > 0) 
		  AND CAST(TxnDate AS date) < ''' + CAST(@Load_Start_Date AS VARCHAR(10)) + '''
		  AND InvDet.DeleteFlag = 0'


	SET @sql2='
	SELECT	 CAST(''' + CONVERT(VARCHAR(10),@PartitionDate, 121) + ''' AS DATE) AS SnapshotDate
		, ISNULL(CAST(' + CAST(@PartitionMonthID AS VARCHAR(6)) + ' AS INT),0) AS SnapshotMonthID
		, ISNULL(V.CitationID,0) AS CitationID
		, CAST(V.CustomerID AS BIGINT) AS CustomerID			   
		, -1 AS AgeStageID
		, Cast(V.CitationStageID AS INT)  AS CitationStageID
		, ISNULL(CAST(V.LaneID AS INT), 0) AS LaneID
		, ISNULL(CAST(V.TPTripID AS BIGINT), 0) AS TPTripId
		, -1 AS InvoiceNumber
		, NULL  AS CurrentInvoiceFlag
		, ISNULL(CAST(V.WriteOffFlag AS BIT), 0) AS WriteOffFlag
		, ISNULL(CAST(V.DeleteFlag as BIT),0) AS DeleteFlag
		, CAST(V.TransactionDate AS DATE) TransactionDate			   
		, ''1900-01-01'' AS InvoiceDate
		, CAST(V.PostedDate AS Date) AS PostedDate
		, '' 1900-01-01 '' AS FirstNoticeFeeDate
		, '' 1900-01-01 '' AS SecondNoticeFeeDate
		, CAST(V.WriteOffDate AS DATE) AS  WriteOffDate
		, CAST(V.TollAmount AS DECIMAL(19,2))  AS TollsDue
		, 0 AS  FirstNoticeFees
		, 0 AS  SecondNoticeFees
		, CAST(V.OutstandingAmount AS DECIMAL(19,2)) AS OutstandingAmount
		, 0 AS FNFeesOutstandingAmount
		, 0 AS SNFeesOutstandingAmount
		, CAST(V.WriteOffAmount AS DECIMAL(19,2)) AS  WriteOffAmount			
		   
		---- Drop columns after MSTR team confirmation
		, CAST(V.TransactionDate AS DATE) TxnDate
		, ISNULL(CAST(SYSDATETIME() AS DATETIME2(3)),''1900-01-01'') EDW_UpdateDate
	FROM  dbo.Fact_Violation V
	WHERE V.OutStandingAmount > 0
		  AND V.CitationStageID=0
		  AND CAST(V.TransactionDate AS DATE) < ''' + CAST(@Load_Start_Date AS VARCHAR(10)) + '''
		  AND V.DeleteFlag=0'
		
	SET @sqlresult= @sql1+' UNION ALL '+@sql2
	SET @sql = ' 
	 IF OBJECT_ID(''' + @StageTableName + ''',''U'') IS NOT NULL			DROP TABLE ' + @StageTableName + ';
	 CREATE TABLE ' + @StageTableName + ' WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CitationId), PARTITION (SnapshotMonthID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + '))) AS
	 ' + @sqlresult + '
	 OPTION (LABEL = ''dbo.Fact_InvoiceAgingSnapshot_NEW'');'


	IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
	
	EXEC (@sql)
	-- Log 
	SET  @Log_Message = 'Loaded dbo.Fact_InvoiceAgingSnapshot_NEW'
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, @sql
		
	-- Create statistics and swap table
	IF @StageTableName = @Main_Table_Name
	BEGIN
		CREATE STATISTICS STATS_Fact_InvoiceAgingSnapshot_001 ON dbo.Fact_InvoiceAgingSnapshot(InvoiceNumber)
		CREATE STATISTICS STATS_Fact_InvoiceAgingSnapshot_002 ON dbo.Fact_InvoiceAgingSnapshot(CitationID)
		CREATE STATISTICS STATS_Fact_InvoiceAgingSnapshot_005 ON dbo.Fact_InvoiceAgingSnapshot(CustomerID)
		CREATE STATISTICS STATS_Fact_InvoiceAgingSnapshot_006 ON dbo.Fact_InvoiceAgingSnapshot(LaneID)
		CREATE STATISTICS STATS_Fact_InvoiceAgingSnapshot_007 ON dbo.Fact_InvoiceAgingSnapshot (TransactionDate)
		CREATE STATISTICS STATS_Fact_InvoiceAgingSnapshot_008 ON dbo.Fact_InvoiceAgingSnapshot (SnapshotDate)
	END
	ELSE
	BEGIN
		IF @Trace_Flag = 1 PRINT 'Calling: Utility.ManagePartitions_DateID'
		EXEC Utility.ManagePartitions_DateID @Main_Table_Name, 'MonthID:Month'

		IF @Trace_Flag = 1 PRINT 'Calling: Utility.PartitionSwitch_Snapshot'
		EXEC Utility.PartitionSwitch_Snapshot 'dbo.Fact_InvoiceAgingSnapshot_NEW',@Main_Table_Name

		UPDATE STATISTICS  dbo.Fact_InvoiceAgingSnapshot

		IF OBJECT_ID('dbo.Fact_InvoiceAgingSnapshot_NEW') IS NOT NULL DROP TABLE dbo.Fact_InvoiceAgingSnapshot_NEW
	END

	SET @Log_Message = 'Finished load for partition ' + CAST(@PartitionDate AS VARCHAR(10))
	IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

	IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Fact_InvoiceAgingSnapshot' TableName, * FROM dbo.Fact_InvoiceAgingSnapshot ORDER BY 2 DESC

END

/*

--:: Testing Zone

EXEC dbo.Fact_InvoiceAgingSnapshot

--:: Quick check
SELECT count(*) FROM EDW_TBOS_DEV.dbo.Fact_InvoiceAgingSnapshot ORDER BY 1
SELECT count(*),SnapshotDate FROM EDW_TBOS_DEV.dbo.Fact_InvoiceAgingSnapshot group by SnapshotDate ORDER BY 1

select * from  dbo.Fact_InvoiceAgingSnapshot

delete  from  dbo.Fact_InvoiceAgingSnapshot where snapshotdate='2020-11-23'


*/




