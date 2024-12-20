CREATE PROC [dbo].[Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_Load] @Load_Start_Date [DATE] AS 

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_Load table by snapshotmonthid 
If table does not exist, creates table; otherwise load to stage table and switch.

This proc is used to identify all the GL_IOP unidentifiedAging Customers. Customers who travel on our roads
having tolltag from different Agencies, We identify the list of customers and sent it to Agency.
At any time, A customer should have both debit and credit record for a txn. If any one of them is missing, then we assign it to a default customerid
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040294	Sagarika Chukka 	2022-12-06	New!
CHG0040527	Sagarika Chukka 	2022-03-02	Modify the DaycountID column based on PartionDate rather then getdate() to calculate the Day differences from PostingDate to PartionDate

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
Exec dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_Load '2022-01-21' 

EXEC Utility.FromLog 'dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_Load', 1
SELECT COUNT_BIG(1) AS CNT FROM dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_Load 
select sum(TxnAmount),snapshotmonthid  FROM dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot
group by snapshotmonthid

select * from Utility.ProcessLog order by 1 desc
###################################################################################################################
*/

BEGIN 
 BEGIN TRY
	--Debug
	--DECLARE @Load_Start_Date [DATE] = CAST(GETDATE() AS DATE)	

	DECLARE @Main_Table_Name VARCHAR(100) = 'dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot'
	DECLARE @StageTableName VARCHAR(100) = 'dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_NEW'
	DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_Load', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
	DECLARE @Log_Message VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing
    DECLARE @sql1 VARCHAR(MAX)
    DECLARE @sql2 VARCHAR(MAX)
    DECLARE @sqlresult VARCHAR(MAX)
    DECLARE @sql VARCHAR(MAX)
	DECLARE @PartitionDate DATE = CAST(DATEADD(DAY,-1,@Load_Start_Date) AS DATE)

	 DECLARE @PartitionMonthID INT = CAST(CONVERT(VARCHAR(6),@PartitionDate,112) AS INT)

	SET @Log_Message = 'Started load for partition ' + CAST(@PartitionDate AS VARCHAR(10))
	IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

 	--=============================================================================================================
	-- Load dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot         
	--=============================================================================================================

	DECLARE @Partition_Ranges VARCHAR(MAX), @LastPartitionID INT = CAST(CONVERT(VARCHAR(6),DATEADD(DAY,1,EOMONTH(@Log_Start_Date,1)),112) AS INT)
	IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_PartitionMonthIDRange_String from 202201 till ' + CAST(@LastPartitionID AS VARCHAR(10))
	EXEC Utility.Get_PartitionMonthIDRange_String 202201, @LastPartitionID, @Partition_Ranges OUTPUT
	
		IF OBJECT_ID(@Main_Table_Name) IS NULL
		SET @StageTableName = @Main_Table_Name

--The following CTE give us the Tolltag Debit/Credit record for an unidentified IOP
        SET @sql1 = '
                    WITH CTE_TT_DR
                    AS ( SELECT
                                   Gl_TxnID
                                 , LinkID                    TPTripID
                                 , CustomerID
                                 , a1.BusinessUnitId
                                 , CAST(PostingDate AS DATE) PostingDate
                                 , CAST(TxnDate AS DATE)     TxnDate
                                 , TxnAmount
                              FROM dbo.Fact_GL_Transactions a1
                              JOIN dbo.Dim_GL_TxnType       a2
                                ON a1.TxnTypeID = a2.TxnTypeID
                             WHERE ( TxnType LIKE ''IOP%UNIDTTDR'' 
                               OR TxnType LIKE ''IOP%UNIDTT'')
                               AND Status     = ''Active''
                               AND CustomerID = 100057393) --   This is a default customer Id used when customers are not yet identified.
                     , CTE_TT_CR
                     AS ( SELECT
                                   Gl_TxnID
                                 , LinkID                    TPTripID
                                 , CustomerID
                                 , a1.BusinessUnitId
                                 , CAST(PostingDate AS DATE) PostingDate
                                 , CAST(TxnDate AS DATE)     TxnDate
                                 , TxnAmount
                              FROM dbo.Fact_GL_Transactions a1
                              JOIN dbo.Dim_GL_TxnType       a2
                                ON a1.TxnTypeID = a2.TxnTypeID
                             WHERE ( TxnType LIKE ''IOP%UNIDTTCR''
                               OR TxnType LIKE ''IOP%UNIDTTREJ'')
                               AND Status     = ''Active''
                               AND CustomerID = 100057393) 
 --The following CTE give us the Video Toll Debit/Credit record for an unidentified IOP

                     , CTE_VT_DR
                     AS ( SELECT
                                   Gl_TxnID
                                 , LinkID                    TPTripID
                                 , CustomerID
                                 , a1.BusinessUnitId
                                 , CAST(PostingDate AS DATE) PostingDate
                                 , CAST(TxnDate AS DATE)     TxnDate
                                 , TxnAmount
                              FROM dbo.Fact_GL_Transactions a1
                              JOIN dbo.Dim_GL_TxnType       a2
                                ON a1.TxnTypeID = a2.TxnTypeID
                             WHERE (TxnType LIKE ''IOP%UNIDVTDR''
                             OR TxnType LIKE ''IOP%UNIDVT'')
                               AND Status     = ''Active''
                               AND CustomerID = 100057393)  
                     , CTE_VT_CR
                     AS ( SELECT
                                   Gl_TxnID
                                 , LinkID                    TPTripID
                                 , CustomerID
                                 , a1.BusinessUnitId
                                 , CAST(PostingDate AS DATE) PostingDate
                                 , CAST(TxnDate AS DATE)     TxnDate
                                 , TxnAmount
                              FROM dbo.Fact_GL_Transactions a1
                              JOIN dbo.Dim_GL_TxnType       a2
                                ON a1.TxnTypeID = a2.TxnTypeID
                               WHERE (
                                 (
                                     TxnType LIKE ''IOP%UNIDVTCR''
                                     OR a2.TxnType LIKE ''IOP%UNIDVTREJ''
                                        AND a1.CustomerID = 100057393
                                 )
                                 OR
                                 (
                                     (
                                         a2.TxnType LIKE ''IOPNTELBJ%VT''
                                         AND a2.TxnType NOT IN ( ''IOPNTELBJUNIDVT'')
                                     )
                                     OR
                                     (
                                         a2.TxnType LIKE ''IOPNTE12%VT''
                                         AND a2.TxnType NOT IN ( ''IOPNTE12UNIDVT'' )
                                     )
                                 )
                             )
                             AND Status = ''Active'')
--AND CustomerID = 100057393)
                       
                    SELECT  CAST(''' + CONVERT(VARCHAR(10),@PartitionDate, 121) + ''' AS DATE) AS SnapshotDate,
                            ISNULL(CAST(' + CAST(@PartitionMonthID AS VARCHAR(6)) + ' AS INT),0) AS SnapshotMonthID ,
                            T.Gl_TxnID,
                            T.TPTripID, 
                            FT.LaneID, 
                            T.CustomerID, 
                            T.BusinessUnitId, 
                            T.PostingDate, 
                            T.TxnDate, 
                            T.TxnAmount,
                            DATEDIFF(DAY, T.PostingDate, CAST(''' + CONVERT(VARCHAR(10),@PartitionDate, 121) + '''  AS DATE))  DaycountID
                        
                    FROM  CTE_TT_DR T 
                    JOIN  dbo.Fact_Transaction FT ON T.TPTripID = FT.TPTripID
                    WHERE  T.TPTripID NOT IN ( SELECT TPTripID FROM CTE_TT_CR ) 
                    AND CAST(TxnDate AS date) < ''' + CAST(@Load_Start_Date AS VARCHAR(10)) + ''''

            SET @sql2 = '
                    SELECT CAST(''' + CONVERT(VARCHAR(10),@PartitionDate, 121) + '''  AS DATE) AS SnapshotDate,
                           ISNULL(CAST(' + CAST(@PartitionMonthID AS VARCHAR(6)) + ' AS INT),0) AS SnapshotMonthID,
                            T.Gl_TxnID, 
                            T.TPTripID, 
                            FT.LaneID, 
                            T.CustomerID, 
                            T.BusinessUnitId, 
                            T.PostingDate, 
                            T.TxnDate, 
                            T.TxnAmount,
                            DATEDIFF(DAY, T.PostingDate, CAST(''' + CONVERT(VARCHAR(10),@PartitionDate, 121) + '''  AS DATE))  DaycountID
                     FROM  CTE_VT_DR T
                     JOIN  dbo.Fact_Transaction FT ON T.TPTripID = FT.TPTripID
                     WHERE  T.TPTripID NOT IN ( SELECT TPTripID FROM CTE_VT_CR ) --(497,490 row(s) affected)
                     AND CAST(TxnDate AS date) < ''' + CAST(@Load_Start_Date AS VARCHAR(10)) + ''''

        SET @sqlresult = @sql1 +'UNION'+ @sql2
	     SET @sql = '
         IF OBJECT_ID(''' + @StageTableName + ''',''U'') IS NOT NULL   DROP TABLE ' + @StageTableName + ';
	     CREATE TABLE ' + @StageTableName + ' WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(Gl_TxnID), PARTITION (SnapshotMonthID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + '))) AS
	    ' + @sqlresult + '

	     OPTION (LABEL = ''dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_NEW'');'

    IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
    EXEC (@sql)
    
    SET @Log_Message = 'Loaded dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_NEW';
    EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message,'I',-1,NULL;
    
    IF @StageTableName = @Main_Table_Name -- First Time Load
    BEGIN
  
		-- Statistics
		CREATE STATISTICS STATS_Fact_GL_IOP_000 ON dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot (Gl_TxnID)
		CREATE STATISTICS STATS_Fact_GL_IOP_001 ON dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot (TPTripID)
		CREATE STATISTICS STATS_Fact_GL_IOP_002 ON dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot (LaneID)
		CREATE STATISTICS STATS_Fact_GL_IOP_003 ON dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot (CustomerID)
		CREATE STATISTICS STATS_Fact_GL_IOP_004 ON dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot (PostingDate)
		CREATE STATISTICS STATS_Fact_GL_IOP_005 ON dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot (TxnDate)
        CREATE STATISTICS STATS_Fact_GL_IOP_006 ON dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot (TxnAmount)


    END
	ELSE
	BEGIN
		IF @Trace_Flag = 1 PRINT 'Calling: Utility.ManagePartitions_DateID'
		EXEC Utility.ManagePartitions_DateID @Main_Table_Name, 'MonthID:Month'

		IF @Trace_Flag = 1 PRINT 'Calling: Utility.PartitionSwitch_Snapshot'
		EXEC Utility.PartitionSwitch_Snapshot 'dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_NEW',@Main_Table_Name

		UPDATE STATISTICS  dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot

        IF OBJECT_ID('dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_NEW') IS NOT NULL DROP TABLE dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_NEW

    SET @Log_Message = 'Finished load for partition ' + CAST(@PartitionDate AS VARCHAR(10))
	
    IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

	IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot' TableName, * FROM dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot ORDER BY 2 DESC
 END 
   
   END TRY
	BEGIN CATCH
	
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH;
     
 END


/*

--:: Testing Zone

EXEC Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_Load '2022-01-25'

-- Example to see a full cycle  of the customer
SELECT a2.TxnType,a1.* FROM dbo.Fact_GL_Transactions a1
JOIN dbo.Dim_GL_TxnType a2
ON a1.TxnTypeID=a2.TxnTypeID
WHERE linkid=3268400701
ORDER BY 2

SELECT * FROM lnd_tbos.TollPlus.TP_Trips
WHERE TpTripID=3268400701

--:: Quick check
SELECT count(*) FROM dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot ORDER BY 1
SELECT count(*),SnapshotDate FROM dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot group by SnapshotDate ORDER BY 1

select top 1 * from  dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot
select top 1 * from  dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot_new

delete  from  dbo.Fact_GL_IOP_UnidentifiedAgingTxnSnapshot 
where snapshotmonthid in ('202110','202111','202112','202201')

*/




