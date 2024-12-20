CREATE PROC [dbo].[Fact_CustomerBalanceSnapshot_Load] @Load_Start_Date [DATE] AS 

/*
#################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_CustomerBalanceSnapshot table for each customer by snapshot month 
If table does not exist, creates table; otherwise load to stage table and switch partitions
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Sagarika,Shankar	2021-8-26	New!
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
Exec dbo.Fact_CustomerBalanceSnapshot_Load '2021-10-01' 
===================================================================================================================
*/
BEGIN 	
  BEGIN TRY
  	-- Debug
    -- DECLARE @Load_Start_Date [DATE] = NULL
	DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_CustomerBalanceSnapshot_Load'
    DECLARE @Main_Table_Name VARCHAR(100) = 'dbo.Fact_CustomerBalanceSnapshot'
    DECLARE @StageTableName VARCHAR(100) = 'dbo.Fact_CustomerBalanceSnapshot_NEW'
    DECLARE @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
	DECLARE @Log_Message VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing
	DECLARE @sql VARCHAR(MAX)

    DECLARE @StartDate DATETIME2(3) = CONVERT(DATE,DATEADD(DAY,1,EOMONTH(ISNULL(@Load_Start_Date,SYSDATETIME()),-2))) 
    DECLARE @EndDate DATETIME2(3) = CONVERT(DATETIME2(3),DATEADD(MS,-2,CONVERT(DATETIME,DATEADD(DAY,1,EOMONTH(ISNULL(@Load_Start_Date,SYSDATETIME()),-1)))))
	DECLARE @SnapshotMonthID INT = CAST(CONVERT(VARCHAR(6),@EndDate,112) AS INT)
    IF @Trace_Flag = 1 SELECT @StartDate [@StartDate], @EndDate [@EndDate], @SnapshotMonthID [@SnapshotMonthID]
   
	SET @Log_Message = 'Started load for partition ' + CAST(@SnapshotMonthID AS VARCHAR(10)) + ' from ' + CONVERT(VARCHAR(19),@StartDate,121) + ' to ' +  CONVERT(VARCHAR(19),@EndDate,121)
    IF @Trace_Flag = 1 PRINT @Log_Message
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL

	--=============================================================================================================
	-- Load dbo.Fact_CustomerBalanceSnapshot        
	--=============================================================================================================
	
	DECLARE @Partition_Ranges VARCHAR(MAX), @LastPartitionID INT = CAST(CONVERT(VARCHAR(6),DATEADD(DAY,1,EOMONTH(@Log_Start_Date,1)),112) AS INT)
	EXEC Utility.Get_PartitionMonthIDRange_String 202101, @LastPartitionID, @Partition_Ranges OUTPUT
	IF @Trace_Flag = 1 PRINT 'Calling: Utility.Get_PartitionMonthIDRange_String from 202101 till ' + CAST(@LastPartitionID AS VARCHAR(10)) + ': ' + @Partition_Ranges
	
	IF OBJECT_ID(@Main_Table_Name) IS NULL
		SET @StageTableName = @Main_Table_Name

	IF OBJECT_ID('Stage.CustomerBalanceWithActivity') IS NOT NULL DROP TABLE Stage.CustomerBalanceWithActivity;
    CREATE TABLE Stage.CustomerBalanceWithActivity WITH (DISTRIBUTION = HASH(CustomerID)) AS 
	SELECT  ISNULL(SnapshotMonthID,-1) AS SnapshotMonthID
          , ISNULL(CAST(CTS.CustomerID AS INT),-1) AS CustomerID
          , CAST(@EndDate AS DATE) AS BalanceDate
          , ISNULL(CAST(CTS.TollTxnCount AS INT),0) TollTxnCount
          , ISNULL(CAST(CTS.CreditAmount AS DECIMAL(19,2)),0) CreditAmount
          , ISNULL(CAST(CTS.DebitAmount AS DECIMAL(19,2)),0) DebitAmount
          , ISNULL(CAST(CTS.CreditTxnCount AS INT),0) CreditTxnCount
          , ISNULL(CAST(CTS.DebitTxnCount AS INT),0) DebitTxnCount
          , ISNULL(CAST(BB.PreviousBalance AS DECIMAL(19,2)),0) AS BeginningBalanceAmount
          , ISNULL(CAST(EB.CurrentBalance AS DECIMAL(19,2)),0) AS EndingBalanceAmount
          , ISNULL(CAST(BB.PreviousBalance + CreditAmount + DebitAmount AS DECIMAL(19,2)),0) CalcEndingBalanceAmount
          , ISNULL(CAST(EB.CurrentBalance - (BB.PreviousBalance + CreditAmount + DebitAmount) AS DECIMAL(19,2)),0) BalanceDiffAmount
          , CTS.BeginningCustTxnID
          , CTS.EndingCustTxnID
          , CONVERT(DATETIME2(3),SYSDATETIME()) EDW_UpdateDate
    FROM 
            (
                SELECT  CAST(LEFT(CONVERT(VARCHAR,PostedDate,112),6) AS INT) AS SnapshotMonthID
                      , CT.CustomerID
                      , SUM(CASE WHEN CT.LinkSourceName = 'TOLLPLUS.TP_CUSTOMERTRIPS' THEN 1 ELSE 0 END) TollTxnCount
                      , SUM(CASE WHEN CT.TxnAmount < 0 THEN CT.TxnAmount ELSE 0 END) DebitAmount 
                      , SUM(CASE WHEN CT.TxnAmount > 0 THEN CT.TxnAmount ELSE 0 END) CreditAmount
                      , SUM(CASE WHEN CT.TxnAmount < 0 THEN 1 ELSE 0 END) CreditTxnCount
                      , SUM(CASE WHEN CT.TxnAmount > 0 THEN 1 ELSE 0 END) DebitTxnCount
                      , MIN(CT.CustTxnID) BeginningCustTxnID 
                      , MAX(CT.CustTxnID) EndingCustTxnID
                  FROM  LND_TBOS.TollPlus.TP_CustTxns       CT
                  JOIN  LND_TBOS.TollPlus.TP_Customer_Plans CP
                    ON  CP.CustomerID = CT.CustomerID AND CT.LND_UpdateType <> 'D'
                WHERE   CP.PlanID = 3 
                        AND CT.PostedDate BETWEEN @StartDate AND @EndDate      
                        AND CT.BalanceType = 'TollBal'
                        AND CT.AppTxnTypeCode NOT LIKE '%FAIL%'          
                       --AND  ct.CustomerID = 4007342
                GROUP BY CT.CustomerID, LEFT(CONVERT(VARCHAR,PostedDate,112),6) 
            ) CTS
    JOIN  LND_TBOS.TollPlus.TP_CustTxns       BB 
      ON  BB.CustTxnID = CTS.BeginningCustTxnID
    JOIN  LND_TBOS.TollPlus.TP_CustTxns       EB 
      ON  EB.CustTxnID = CTS.EndingCustTxnID

    EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Loaded Stage.CustomerBalanceWithActivity', 'I', -1, NULL

	IF OBJECT_ID('Stage.CustomerBalanceWithNoActivity') IS NOT NULL DROP TABLE Stage.CustomerBalanceWithNoActivity;
    CREATE TABLE Stage.CustomerBalanceWithNoActivity WITH (DISTRIBUTION = HASH(CustomerID)) AS 
	    SELECT  ISNULL(CAST(@SnapshotMonthID AS INT),-1) AS SnapshotMonthID
              , ISNULL(CAST(CTS.CustomerID AS INT),-1) AS CustomerID
              , CAST(@EndDate AS DATE) BalanceDate
              , ISNULL(CAST(0 AS INT),0) TollTxnCount
              , ISNULL(CAST(0 AS DECIMAL(19,2)),0) CreditAmount
              , ISNULL(CAST(0 AS DECIMAL(19,2)),0) DebitAmount
              , ISNULL(CAST(0 AS INT),0) CreditTxnCount
              , ISNULL(CAST(0 AS INT),0) DebitTxnCount
              , ISNULL(CAST(EB.CurrentBalance AS DECIMAL(19,2)),0) AS BeginningBalanceAmount
              , ISNULL(CAST(EB.CurrentBalance AS DECIMAL(19,2)),0) AS EndingBalanceAmount
              , ISNULL(CAST(EB.CurrentBalance AS DECIMAL(19,2)),0) CalcEndingBalanceAmount
              , ISNULL(CAST(0 AS DECIMAL(19,2)),0) BalanceDiffAmount
              , ISNULL(CAST(0 AS INT),0) BeginningCustTxnID
              , CTS.LastCustTxnID AS EndingCustTxnID
              , CONVERT(DATETIME2(3),SYSDATETIME()) EDW_UpdateDate
    FROM 
            (
                SELECT  CT.CustomerID
                      , MAX(CT.PostedDate) LastPostedDate
                      , MAX(CT.CustTxnID) LastCustTxnID
                  FROM  LND_TBOS.TollPlus.TP_CustTxns       CT
                  JOIN  LND_TBOS.TollPlus.TP_Customer_Plans CP
                    ON  CP.CustomerID = CT.CustomerID   AND CT.LND_UpdateType <> 'D'
                   WHERE  CP.PlanID = 3 
                   AND  CT.PostedDate < @StartDate
                   AND  CT.BalanceType = 'TollBal'
                   AND AppTxnTypeCode NOT LIKE '%FAIL%'        
                   AND  NOT EXISTS (SELECT 1 FROM Stage.CustomerBalanceWithActivity AEB WHERE CT.CustomerID = AEB.CustomerID)
                GROUP BY CT.CustomerID 
            ) CTS
    JOIN  LND_TBOS.TollPlus.TP_CustTxns       EB 
      ON  EB.CustTxnID = CTS.LastCustTxnID

    EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Loaded Stage.CustomerBalanceWithNoActivity', 'I', -1, NULL

    SET @sql = ' 
	     IF OBJECT_ID(''' + @StageTableName + ''',''U'') IS NOT NULL    DROP TABLE ' + @StageTableName + ';
	     CREATE TABLE ' + @StageTableName + ' WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CustomerID), PARTITION (SnapshotMonthID RANGE RIGHT FOR VALUES (' + @Partition_Ranges + '))) AS
	     SELECT * FROM Stage.CustomerBalanceWithActivity  
         UNION ALL 
         SELECT * FROM Stage.CustomerBalanceWithNoActivity
	     OPTION (LABEL = ''dbo.Fact_CustomerBalanceSnapshot_NEW'');'

    IF @Trace_Flag = 1 EXEC Utility.LongPrint @sql
	
	EXEC (@sql)

	-- Log 
	SET  @Log_Message = 'Loaded ' + @StageTableName
	EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, @sql

    -- Create statistics and swap table
	IF @StageTableName = @Main_Table_Name
	BEGIN
		CREATE STATISTICS STATS_FactCustomerBalanceSnapshot_000 ON dbo.Fact_CustomerBalanceSnapshot (SnapshotMonthID)
		CREATE STATISTICS STATS_FactCustomerBalanceSnapshot_001 ON dbo.Fact_CustomerBalanceSnapshot (CustomerID)
		CREATE STATISTICS STATS_FactCustomerBalanceSnapshot_002 ON dbo.Fact_CustomerBalanceSnapshot (BalanceDate)
		CREATE STATISTICS STATS_FactCustomerBalanceSnapshot_004 ON dbo.Fact_CustomerBalanceSnapshot (BeginningCustTxnID)
		CREATE STATISTICS STATS_FactCustomerBalanceSnapshot_005 ON dbo.Fact_CustomerBalanceSnapshot (EndingCustTxnID)
     END
	ELSE
	BEGIN
		IF @Trace_Flag = 1 PRINT 'Calling: Utility.ManagePartitions_DateID'
		EXEC Utility.ManagePartitions_DateID @Main_Table_Name, 'MonthID:Month'

		IF @Trace_Flag = 1 PRINT 'Calling: Utility.PartitionSwitch_Snapshot'
		EXEC Utility.PartitionSwitch_Snapshot 'dbo.Fact_CustomerBalanceSnapshot_NEW', @Main_Table_Name

		UPDATE STATISTICS  dbo.Fact_CustomerBalanceSnapshot                                                    

		--IF OBJECT_ID('dbo.Fact_CustomerBalanceSnapshot_NEW') IS NOT NULL DROP TABLE dbo.Fact_CustomerBalanceSnapshot_NEW
	END
	
    -- Log
	SET @Log_Message = 'Finished load for partition ' + CAST(@SnapshotMonthID AS VARCHAR(10))
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
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
Exec dbo.Fact_CustomerBalanceSnapshot_Load '2021-10-01' 

EXEC Utility.FromLog 'dbo.Fact_CustomerBalanceSnapshot_Load', 1
SELECT TOP 100 'dbo.Fact_CustomerBalanceSnapshot_Load' Table_Name, * FROM dbo.Fact_CustomerBalanceSnapshot_Load ORDER BY 1,2

--===============================================================================================================
-- DYNAMIC SQL STRING
--===============================================================================================================
IF OBJECT_ID('dbo.Fact_CustomerBalanceSnapshot','U') IS NOT NULL    DROP TABLE dbo.Fact_CustomerBalanceSnapshot;
CREATE TABLE dbo.Fact_CustomerBalanceSnapshot WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CustomerID), PARTITION (SnapshotMonthID RANGE RIGHT FOR VALUES (202101,202102,202103,202104,202105,202106,202107,202108,202109,202110,202111,202112))) AS
SELECT * FROM Stage.CustomerBalanceWithActivity  
UNION ALL 
SELECT * FROM Stage.CustomerBalanceWithNoActivity
OPTION (LABEL = 'dbo.Fact_CustomerBalanceSnapshot_NEW');

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================

-------------------------------------------------------------------------------------------------------------------
--:: Data Monitor Query 1. TollTag Customer Current Balance Amount is not same in TP_Customer_Balances and TP_CustTxns tables
-------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb.dbo.#TP_Customer_Balances') IS NOT NULL DROP TABLE #TP_Customer_Balances
IF OBJECT_ID('tempdb.dbo.#TP_CustTxns') IS NOT NULL DROP TABLE #TP_CustTxns
IF OBJECT_ID('tempdb.dbo.#Diff') IS NOT NULL DROP TABLE #Diff

SELECT CustomerID, BalanceAmount 
INTO #TP_Customer_Balances
FROM LND_TBOS.TOLLPLUS.TP_CUSTOMER_BALANCES eb
WHERE BALANCETYPE = 'TollBal'	
      AND EXISTS (SELECT 1 FROM LND_TBOS.TOLLPLUS.TP_CUSTOMER_PLANS cp WHERE cp.CustomerID = eb.CustomerID)
      AND LND_UpdateType <> 'D'									
 								
SELECT a.CustomerID, a.CurrentBalance 
INTO #TP_CustTxns       
FROM LND_TBOS.TollPlus.TP_CustTxns a									
    JOIN									
    (									
        SELECT MAX(CustTxnID) AS Maxid,									
               CustomerID									
        FROM LND_TBOS.TollPlus.TP_CustTxns									
        WHERE BalanceType= 'TollBal'									
              AND LND_UpdateType <> 'D'									
        GROUP BY CustomerID									
    ) b									
        ON a.CustomerID = b.CustomerID									
           AND a.CustTxnID = Maxid									
WHERE EXISTS (SELECT 1 FROM LND_TBOS.TOLLPLUS.TP_CUSTOMER_PLANS cp WHERE cp.CustomerID = a.CustomerID)

SELECT 'In TP_Customer_Balances' TABLENAME, * INTO #Diff 
	FROM
		(SELECT * FROM #TP_Customer_Balances
		 EXCEPT
		 SELECT * FROM #TP_CustTxns) X
	UNION ALL
	SELECT 'In TP_CustTxns' TABLENAME, *  
	FROM
		(SELECT * FROM #TP_CustTxns
		 EXCEPT 
		 SELECT * FROM #TP_Customer_Balances) X

SELECT * FROM #Diff WHERE BalanceAmount <> 0
UNION
SELECT * FROM #Diff d1 WHERE BalanceAmount = 0 AND EXISTS (SELECT 1 FROM #Diff d2 WHERE d1.CustomerID = d2.CustomerID and d2.BalanceAmount <> 0)
ORDER BY 2,1

-------------------------------------------------------------------------------------------------------------------
--:: Data Monitor Query 2.Disconnect between OpeningBalance of TollBal Txn vs previous txn EndingBalance in TP_CustTxn table
-------------------------------------------------------------------------------------------------------------------
SELECT *
FROM
(
    SELECT CustTxnID,
            CustomerID,
            BalanceType,
            PostedDate,
            TxnAmount,
            PreviousBalance,
            CurrentBalance,
            PreviousBalance - LAG(currentbalance) OVER (partition BY CustomerID ORDER BY custtxnid) OpeningBalToPrevEndingBalDiff
    FROM LND_TBOS.TollPlus.TP_CustTxns
    WHERE balancetype = 'TOLLBAL'
        AND LND_UpdateType <> 'D'				
) t
WHERE OpeningBalToPrevEndingBalDiff <> 0 	
ORDER BY CustomerID, CustTxnID

---------------------------------------------------------------------------------------------------------------------------
--:: Data Monitor Query 3. TollTag Accounts Opening Balance To Ending Balance Calculation errors for previous month
---------------------------------------------------------------------------------------------------------------------------
SELECT CustomerID, CONVERT(DATE,DATEADD(DAY,1,EOMONTH(SYSDATETIME(),-2))) OpeningBalanceDate, BalanceDate AS EndingBalanceDate, TollTxnCount, CreditAmount, DebitAmount, CreditTxnCount, DebitTxnCount, BeginningBalanceAmount, EndingBalanceAmount, CalcEndingBalanceAmount, BalanceDiffAmount, BeginningCustTxnID, EndingCustTxnID 
FROM EDW_TRIPS.dbo.Fact_CustomerBalanceSnapshot 
WHERE BalanceDiffAmount <> 0 AND SnapshotMonthID = CAST(CONVERT(VARCHAR(6),CONVERT(DATETIME2(3),DATEADD(MS,-2,CONVERT(DATETIME,DATEADD(DAY,1,EOMONTH(SYSDATETIME(),-1))))),112) AS INT)
ORDER BY CustomerID

---------------------------------------------------------------------------------------------------------------------------
--:: Data Monitor Query 4. Opening Balance To Ending Balance Calculation Diff in TP_CustTxn table
---------------------------------------------------------------------------------------------------------------------------
SELECT CP.PlanID, CT.CustTxnID, CT.CustomerID, CT.PostedDate, CT.BalanceType, ct.CustTxnCategory, CT.TxnAmount, CT.PreviousBalance, CT.CurrentBalance, PreviousBalance + TxnAmount	AS 	CalcCurrentBalance, CurrentBalance - (PreviousBalance + TxnAmount) AS BalanceDiff								
FROM LND_TBOS.TOLLPLUS.TP_CUSTTXNS CT											
JOIN LND_TBOS.TollPlus.TP_Customer_Plans CP											
ON CT.CustomerID = CP.CustomerID
WHERE PreviousBalance + TxnAmount  <> CurrentBalance
AND CT.LND_UpdateType <> 'D'
AND CP.LND_UpdateType <> 'D'
ORDER BY 1,2,3

-------------------------------------------------------------------------------------------------------------------
--:: Data Monitor Query 5. Prepaid Accounts having BalanceType = VioBal or NULL in TP_CustTxns table [DFCT0010086]
-------------------------------------------------------------------------------------------------------------------
SELECT  CT.CustomerID 
        , CP.PlanID
        , CT.BalanceType  
        , SUM(CASE WHEN CT.TxnAmount < 0 THEN CT.TxnAmount ELSE 0 END) DebitAmount 
        , SUM(CASE WHEN CT.TxnAmount > 0 THEN CT.TxnAmount ELSE 0 END) CreditAmount
        , SUM(CASE WHEN CT.TxnAmount < 0 THEN 1 ELSE 0 END) CreditTxnCount
        , SUM(CASE WHEN CT.TxnAmount > 0 THEN 1 ELSE 0 END) DebitTxnCount
        , COUNT_BIG(1) TotalTxnCount
        , MIN(PostedDate) PostedDateFrom
        , MAX(PostedDate) PostedDateTo											
FROM LND_TBOS.TOLLPLUS.TP_CUSTTXNS CT											
JOIN LND_TBOS.TollPlus.TP_Customer_Plans CP											
ON CT.CustomerID = CP.CustomerID
AND CT.LND_UpdateType <> 'D'
AND CP.LND_UpdateType <> 'D'
WHERE ISNULL(CT.BalanceType,'VioBal') = 'VioBal'	
AND CP.PlanID = 3
GROUP BY CT.CustomerID, CP.PlanID, CT.BalanceType
ORDER BY 1

*/



