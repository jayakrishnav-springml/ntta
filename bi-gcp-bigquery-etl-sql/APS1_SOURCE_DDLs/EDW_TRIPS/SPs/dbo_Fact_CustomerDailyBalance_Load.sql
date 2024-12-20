CREATE PROC [dbo].[Fact_CustomerDailyBalance_Load] @Load_Start_Date [DATE],@IsFullLoad [BIT] AS
/*
#################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
1. Load dbo.Fact_CustomerDailyBalance table for each TollTag Customer by day. It's a Slowly Changing Fact table (SCF)!

2. It's a Slowly Changing Fact table (SCF)! Fact Table design consdieration:  
   Normal fact table: 5.2 mil rows per day*30*12*2 <== 3.74 billion rows in 2 years. 
                      All 5 million toll tag customers having 1 rec every day, with or without any balance activity.
   SCF              : 1.25 mil cust bal change rows per day*30*12*2 <== 900 million rows in 2 years. 
                      Insert a new daily balance row ONLY IF THERE IS A BALANCE CHANGE ON THAT DAY FOR THE ACCOUNT.
   
   SCF approach gives a gain of 4.2 times reduction in the number of fact table rows over a period of time.

3. History of daily customer balance is available from the load start cutoff date,i.e., 2021-01-01.

4. If customer has no CustTxn activity since 2021-01-01, just show the current balance from the last CustTxn before 2023-01-01.

===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0044064	Sagarika, Shankar 	2023-02-06	New!
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_CustomerDailyBalance_Load @Load_Start_Date = NULL, @IsFullLoad = 1 -- Full Load
EXEC dbo.Fact_CustomerDailyBalance_Load @Load_Start_Date = NULL, @IsFullLoad = 0 -- Incremental Load
EXEC dbo.Fact_CustomerDailyBalance_Load @Load_Start_Date = '2023-11-01', @IsFullLoad = 0 -- Reload

SELECT TOP 100 * FROM Utility.ProcessLog WHERE LogSource = 'dbo.Fact_CustomerDailyBalance_Load' ORDER BY 1 DESC
SELECT TOP 100 'dbo.Fact_CustomerDailyBalance_Load' Table_Name, * FROM dbo.Fact_CustomerDailyBalance ORDER BY 1,2
===================================================================================================================
*/

BEGIN
    BEGIN TRY
        -- DEBUG
        --DECLARE @Load_Start_Date DATE = NULL, @IsFullLoad BIT = 1 -- Round 1. New. Full Load
        --DECLARE @Load_Start_Date DATE = NULL, @IsFullLoad BIT = 0 -- Round 2. Incr. 2023-11-01 load.
        --DECLARE @Load_Start_Date DATE = '2023-10-25', @IsFullLoad BIT = 0 -- Round 2. Incr. 2023-10-25 reload.
        
        DECLARE @Log_Source VARCHAR(100) = 'dbo.Fact_CustomerDailyBalance_Load'
        DECLARE @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
        DECLARE @Log_Message VARCHAR(1000), @Trace_Flag BIT = 0 -- Testing

        DECLARE @BalanceStartDate DATE, @BalanceEndDate DATE, @LND_DataAsOfDate DATETIME, @Fact_Max_BalanceStartDate DATE, @FirstBalanceLoadDate DATE = '2021-01-01' /*Testing: '2023-10-01' Prod value: '2021-01-01'*/
 
 	    --=============================================================================================================
	    -- Get BalanceStartDate and BalanceEndDate for the current run
	    --=============================================================================================================

       --:: BalanceStartDate
        IF  OBJECT_ID('dbo.Fact_CustomerDailyBalance') IS NULL OR @IsFullLoad = 1
        BEGIN
            SELECT @IsFullLoad = 1, @BalanceStartDate = @FirstBalanceLoadDate /*Testing. Round 1 value: '2023-10-21'  Prod value: @FirstBalanceLoadDate*/
        END
        ELSE
        BEGIN
            IF  @Load_Start_Date IS NULL 
                SELECT  @BalanceStartDate = DATEADD(DAY,1,MAX(BalanceStartDate)), @Fact_Max_BalanceStartDate = MAX(BalanceStartDate)
                FROM    dbo.Fact_CustomerDailyBalance
            ELSE 
                SELECT  @BalanceStartDate = @Load_Start_Date 
        END
   
        --:: Daily incremental load. TP_CustTxns data received thru CDC for the last 24 hours can have rows with PostedDate older than last 24 hours. Reload the fact table from the min PostedDate onwards.
        IF  @IsFullLoad = 0
        BEGIN
            WITH CTE_SD AS
            (
                SELECT  LND_UpdateDate, CONVERT(DATE,PostedDate) PostedDate, MIN(PostedDate) MIN_PostedDate, MAX(PostedDate) MAX_PostedDate, COUNT_BIG(1) RC
                FROM    LND_TBOS.TollPlus.TP_CustTxns
                WHERE   LND_UpdateDate > ISNULL(@Fact_Max_BalanceStartDate, @Load_Start_Date)
                GROUP   BY LND_UpdateDate, CONVERT(DATE,PostedDate)
            )
            SELECT @BalanceStartDate = ISNULL(MIN(PostedDate),@FirstBalanceLoadDate) FROM CTE_SD
        END
        
        --:: BalanceEndDate
        SELECT  @LND_DataAsOfDate = MAX(PostedDate) FROM LND_TBOS.TollPlus.TP_CustTxns 
        --WHERE   PostedDate < '2023-11-02 00:00' /*Testing: Simulate controlled full load and incremental load data. Comment in Prod*/ 
        
        SELECT  @BalanceEndDate = CASE WHEN CAST(@LND_DataAsOfDate AS TIME) = '23:59:59.000' THEN @LND_DataAsOfDate ELSE CONVERT(DATE,DATEADD(DAY,-1,@LND_DataAsOfDate)) END
        
        --> How can BalanceStartDate be after BalanceEndDate? Result: No output from this run. 
        IF @BalanceStartDate > @BalanceEndDate
        BEGIN
 		    SET @Log_Message =  'Attention! Balance Start Date ' + ISNULL(CONVERT(VARCHAR,@BalanceStartDate),'???') + ' is after Balance End Date ' + ISNULL(CONVERT(VARCHAR,@BalanceEndDate),'???') + 
                                ISNULL('! LND data "as of date" ' + CONVERT(VARCHAR,@LND_DataAsOfDate,121),'') + ' Result: No output from this run.'
            IF @Trace_Flag = 1 PRINT @Log_Message 
		    EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
        END
        --> BalanceStartDate cannot be more than 1 day prior to "data as of date". Result: No output from this run. 
        IF (@BalanceStartDate > @LND_DataAsOfDate OR @BalanceEndDate > @LND_DataAsOfDate)
        BEGIN
 		    SET @Log_Message =  'Attention! Balance Start Date ' + ISNULL(CONVERT(VARCHAR,@BalanceStartDate),'???') + ' or Balance End Date ' + ISNULL(CONVERT(VARCHAR,@BalanceEndDate),'???') + 
                                ' is after LND data "as of date" ' + ISNULL(CONVERT(VARCHAR,@LND_DataAsOfDate,121),'???') + '! Result: No output from this run.'
            IF @Trace_Flag = 1 PRINT @Log_Message
		    EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
        END

        --:: Balance load dates table. Driving input all three modes of run: Full load, Daily incremental load, On demand load from a start date.
	    IF OBJECT_ID('TEMPDB.dbo.#BalanceDate') IS NOT NULL DROP TABLE #BalanceDate
        CREATE TABLE #BalanceDate WITH (DISTRIBUTION = REPLICATE) AS
        SELECT  DayDate AS BalanceStartDate ,
                DATEADD(MS,-2,DATEADD(DAY,1,CONVERT(DATETIME2(3),CONVERT(VARCHAR(8),DayDate,112)))) AS BalanceEndDate 
	    INTO    #BalanceDate
        FROM    dbo.Dim_Day
        WHERE   DayDate BETWEEN @BalanceStartDate AND @BalanceEndDate
   
	    IF @Trace_Flag = 1 SELECT '#BalanceDate' SRC, * FROM #BalanceDate ORDER BY BalanceStartDate DESC

	    DECLARE @Partition_Ranges VARCHAR(MAX), 
                @FirstPartitionDate DATE = '2020-12-01',
                @LastPartitionDate DATE = DATEADD(DAY,1,EOMONTH(@BalanceEndDate,1))
        DECLARE @SQL VARCHAR(MAX), @CreateTableWith VARCHAR(MAX)

        IF @Trace_Flag = 1 
        SELECT  @Load_Start_Date [@Load_Start_Date], @LND_DataAsOfDate [@LND_DataAsOfDate], 
                @Fact_Max_BalanceStartDate [@Fact_Max_BalanceStartDate], 
                @BalanceStartDate [@BalanceStartDate], @BalanceEndDate [@BalanceEndDate], @FirstBalanceLoadDate [@FirstBalanceLoadDate],
                @FirstPartitionDate [@FirstPartitionDate],@LastPartitionDate [@LastPartitionDate]
	   
        IF @IsFullLoad = 1
        BEGIN
		    EXEC Utility.Get_PartitionDateRange_String @FirstPartitionDate, @LastPartitionDate, @Partition_Ranges OUTPUT
            SET @CreateTableWith = '(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CustomerID), PARTITION (BalanceStartDate RANGE RIGHT FOR VALUES (' + @Partition_Ranges + ')))'

		    SET @Log_Message = 'Started Full Load from BalanceStartDate ' + ISNULL(CONVERT(VARCHAR,@BalanceStartDate),'???') + ' to BalanceEndDate ' + ISNULL(CONVERT(VARCHAR,@BalanceEndDate),'???') + 
                                '. @LND_DataAsOfDate: ' + ISNULL(CONVERT(VARCHAR,@LND_DataAsOfDate,121),'???') + '. @FirstBalanceLoadDate: ' + ISNULL(CONVERT(VARCHAR,@FirstBalanceLoadDate),'???')
            IF @Trace_Flag = 1 PRINT @Log_Message+ '. @CreateTableWith: ' + @CreateTableWith
		    EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
	    END
	    ELSE
	    BEGIN
			SET @CreateTableWith = '(CLUSTERED INDEX (CustomerID), DISTRIBUTION = HASH(CustomerID))'

		    SET @Log_Message = 'Started Incremental Load from BalanceStartDate ' + ISNULL(CONVERT(VARCHAR,@BalanceStartDate),'???') + ' to BalanceEndDate ' + ISNULL(CONVERT(VARCHAR,@BalanceEndDate),'???') + 
                                '. @Load_Start_Date: ' + ISNULL(CONVERT(VARCHAR,@Load_Start_Date,121),'???') + 
                                ' & @Fact_Max_BalanceStartDate (both can determine BalanceStartDate based on MIN(PostedDate) in TP_CustTxns table having LND_UpdateDate > @Fact_Max_BalanceStartDate or @Load_Start_Date): ' + ISNULL(CONVERT(VARCHAR,@Fact_Max_BalanceStartDate,121),'???') +
                                '. @LND_DataAsOfDate (determines BalanceEndDate): ' + ISNULL(CONVERT(VARCHAR,@LND_DataAsOfDate,121),'???') 
            IF @Trace_Flag = 1 PRINT @Log_Message+ '. @CreateTableWith: ' + @CreateTableWith
			EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
	    END

	    --=============================================================================================================
	    -- Load dbo.Fact_CustomerBalanceSnapshot        
	    --=============================================================================================================

        -- Insert a new record into the stage history table with Activity on a given Date
	    IF OBJECT_ID('Stage.CustomerDailyBalanceWithActivity') IS NOT NULL DROP TABLE Stage.CustomerDailyBalanceWithActivity;
        CREATE TABLE Stage.CustomerDailyBalanceWithActivity WITH (CLUSTERED INDEX(CustomerID), DISTRIBUTION = HASH(CustomerID)) AS 
	    SELECT  ISNULL(CAST(CTS.CustomerID AS INT),-1) AS CustomerID
                , CAST(BB.PostedDate AS DATE) AS BalanceStartDate
                , ISNULL(CAST(CTS.TollTxnCount AS INT),0) TollTxnCount
                , ISNULL(CAST(CTS.TollAmount AS DECIMAL(19,2)),0) TollAmount
                , ISNULL(CAST(CTS.CreditAmount AS DECIMAL(19,2)),0) CreditAmount
                , ISNULL(CAST(CTS.DebitAmount AS DECIMAL(19,2)),0) DebitAmount
                , ISNULL(CAST(CTS.CreditTxnCount AS INT),0) CreditTxnCount
                , ISNULL(CAST(CTS.DebitTxnCount AS INT),0) DebitTxnCount
                , ISNULL(CAST(BB.PreviousBalance AS DECIMAL(19,2)),0) AS BeginningBalanceAmount
                , ISNULL(CAST(EB.CurrentBalance AS DECIMAL(19,2)),0) AS EndingBalanceAmount
                , ISNULL(CAST(BB.PreviousBalance + CreditAmount + DebitAmount AS DECIMAL(19,2)),0) CalcEndingBalanceAmount
                , ISNULL(CAST(EB.CurrentBalance - (BB.PreviousBalance + CreditAmount + DebitAmount) AS DECIMAL(19,2)),0) BalanceDiffAmount
                , CAST(CTS.BeginningCustTxnID AS BIGINT) BeginningCustTxnID
                , CAST(CTS.EndingCustTxnID AS BIGINT) EndingCustTxnID
                , ISNULL(CAST(SYSDATETIME() AS DATETIME2(3)), '1900-01-01') AS EDW_UpdateDate
		        FROM 
                (
                    SELECT  CT.CustomerID
                            , CONVERT(VARCHAR(8),CT.PostedDate, 112) PostedDate
                            , SUM(CASE WHEN CT.LinkSourceName = 'TOLLPLUS.TP_CUSTOMERTRIPS' THEN 1 ELSE 0 END) TollTxnCount
                            , SUM(CASE WHEN CT.LinkSourceName = 'TOLLPLUS.TP_CUSTOMERTRIPS' THEN CT.TxnAmount * -1 ELSE 0 END) TollAmount
                            , SUM(CASE WHEN CT.TxnAmount < 0 THEN CT.TxnAmount ELSE 0 END) DebitAmount 
                            , SUM(CASE WHEN CT.TxnAmount > 0 THEN CT.TxnAmount ELSE 0 END) CreditAmount
                            , SUM(CASE WHEN CT.TxnAmount < 0 THEN 1 ELSE 0 END) DebitTxnCount
                            , SUM(CASE WHEN CT.TxnAmount > 0 THEN 1 ELSE 0 END) CreditTxnCount
                            , MIN(CT.CustTxnID) BeginningCustTxnID 
                            , MAX(CT.CustTxnID) EndingCustTxnID
                        FROM dbo.Dim_Customer C 
                        JOIN LND_TBOS.TollPlus.TP_CustTxns CT
                        ON CT.CustomerID = C.CustomerID 
                        AND C.AccountCategoryDesc = 'TagStore'
                        AND CT.LND_UpdateType <> 'D'
                        JOIN #BalanceDate BD ON BD.BalanceStartDate =  CONVERT(VARCHAR(8),CT.PostedDate, 112)
                        WHERE CT.BalanceType = 'TollBal'
                            AND CT.AppTxnTypeCode NOT LIKE '%FAIL%'          
                    GROUP BY CT.CustomerID,CONVERT(VARCHAR(8),CT.PostedDate, 112)
                ) CTS
        JOIN  LND_TBOS.TollPlus.TP_CustTxns       BB 
            ON  BB.CustTxnID = CTS.BeginningCustTxnID
        JOIN  LND_TBOS.TollPlus.TP_CustTxns       EB 
            ON  EB.CustTxnID = CTS.EndingCustTxnID

        EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Loaded Stage.CustomerDailyBalanceWithActivity', 'I', -1, NULL

        IF @Trace_Flag = 1 SELECT TOP 100 'Stage.CustomerDailyBalanceWithActivity' SRC, * FROM Stage.CustomerDailyBalanceWithActivity ORDER BY CustomerID, BalanceStartDate
  
        -- Insert a new record into the stage balance history table with No Activity (This row reflects only the last CustTxnID before the BalanceStartDate)
        IF @IsFullLoad = 1
        BEGIN
                IF OBJECT_ID('Stage.CustomerDailyBalanceWithNoActivity') IS NOT NULL DROP TABLE Stage.CustomerDailyBalanceWithNoActivity;
                CREATE TABLE Stage.CustomerDailyBalanceWithNoActivity WITH (CLUSTERED INDEX(CustomerID), DISTRIBUTION = HASH(CustomerID)) AS 
	            SELECT      ISNULL(CAST(CTS.CustomerID AS INT),-1) AS CustomerID
                            , CAST(CTS.BalanceEndDate AS DATE) AS BalanceStartDate
                            , ISNULL(CAST(0 AS INT),0) TollTxnCount
                            , ISNULL(CAST(0 AS DECIMAL(19,2)),0) TollAmount
                            , ISNULL(CAST(0 AS DECIMAL(19,2)),0) CreditAmount
                            , ISNULL(CAST(0 AS DECIMAL(19,2)),0) DebitAmount
                            , ISNULL(CAST(0 AS INT),0) CreditTxnCount
                            , ISNULL(CAST(0 AS INT),0) DebitTxnCount
                            , ISNULL(CAST(EB.CurrentBalance AS DECIMAL(19,2)),0) AS BeginningBalanceAmount
                            , ISNULL(CAST(EB.CurrentBalance AS DECIMAL(19,2)),0) AS EndingBalanceAmount
                            , ISNULL(CAST(EB.CurrentBalance AS DECIMAL(19,2)),0) CalcEndingBalanceAmount
                            , ISNULL(CAST(0 AS DECIMAL(19,2)),0) BalanceDiffAmount
                            , CAST(NULL AS BIGINT) AS BeginningCustTxnID
                            , CTS.LastCustTxnID AS EndingCustTxnID
                            , CAST(SYSDATETIME() AS DATETIME2(3)) AS EDW_UpdateDate
		                FROM 
                        (
                            SELECT  CT.CustomerID
                                    , MAX(CT.PostedDate) BalanceEndDate
                                    , MAX(CT.CustTxnID) LastCustTxnID
                                FROM dbo.Dim_Customer C 
                                JOIN LND_TBOS.TollPlus.TP_CustTxns CT
                                ON CT.CustomerID = C.CustomerID 
                                AND C.AccountCategoryDesc = 'TagStore'
                                AND CT.LND_UpdateType <> 'D'
                                WHERE CT.PostedDate < @BalanceStartDate
                                AND CT.BalanceType = 'TollBal'
                                AND CT.AppTxnTypeCode NOT LIKE '%FAIL%' 
                                AND NOT EXISTS (SELECT 1 FROM Stage.CustomerDailyBalanceWithActivity AEB WHERE CT.CustomerID = AEB.CustomerID)
                                --AND c.CustomerID IN (2007000793)
                            GROUP BY CT.CustomerID 
                        ) CTS
                JOIN  LND_TBOS.TollPlus.TP_CustTxns       EB 
                    ON  EB.CustTxnID = CTS.LastCustTxnID

                EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Loaded Stage.CustomerDailyBalanceWithNoActivity - One time during Full Load', 'I', -1, NULL

                IF @Trace_Flag = 1 SELECT TOP 100 'Stage.CustomerDailyBalanceWithNoActivity' SRC, * FROM Stage.CustomerDailyBalanceWithNoActivity ORDER BY BalanceStartDate DESC, CustomerID
                
                /*
                    SELECT COUNT(*) FROM Stage.CustomerDailyBalanceWithNoActivity WHERE EndingBalanceAmount = 0 -- 1268156 rows out of 3676233 row(s) -- SELECT 1268156/3676233. = 34.5%
                    SELECT COUNT(*) FROM Stage.CustomerDailyBalanceWithNoActivity WHERE EndingBalanceAmount < 0 -- 484690 rows out of 3676233 row(s) -- SELECT 484690/3676233. = 13%
                    SELECT TOP 10 * FROM Stage.CustomerDailyBalanceWithNoActivity WHERE EndingBalanceAmount = 0 -- CustomerID IN (2010747882, 2010619379)CustomerID IN (2010747882, 2010619379)
                    SELECT TOP 10 * FROM Stage.CustomerDailyBalanceWithNoActivity WHERE EndingBalanceAmount < 0 -- CustomerID IN (2010747882, 2010619379)CustomerID IN (2010747882, 2010619379)
                */
        END
        ELSE
        BEGIN
            IF OBJECT_ID ('Stage.CustomerDailyBalanceOpenEnded') IS NOT NULL DROP TABLE Stage.CustomerDailyBalanceOpenEnded; -- (5253238 row(s) affected)							
            CREATE TABLE Stage.CustomerDailyBalanceOpenEnded WITH (CLUSTERED INDEX(CustomerID), DISTRIBUTION = HASH(CustomerID)) AS 							
            SELECT  CustomerID, BalanceStartDate, TollTxnCount, TollAmount, CreditAmount, DebitAmount, CreditTxnCount, DebitTxnCount, BeginningBalanceAmount, EndingBalanceAmount, CalcEndingBalanceAmount, BalanceDiffAmount, BeginningCustTxnID, EndingCustTxnID, CONVERT(DATETIME2(3),SYSDATETIME()) EDW_UpdateDate
            FROM    dbo.Fact_CustomerDailyBalance F
            WHERE   BalanceEndDate = '9999-12-31' -- Open ended row
                    AND EXISTS (SELECT 1 FROM Stage.CustomerDailyBalanceWithActivity BWA WHERE F.CustomerID = BWA.CustomerID)
                
            EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Loaded Stage.CustomerDailyBalanceOpenEnded - Daily during Incremental Load', 'I', -1, NULL

            IF @Trace_Flag = 1 SELECT TOP 100 'Stage.CustomerDailyBalanceOpenEnded' SRC, * FROM Stage.CustomerDailyBalanceOpenEnded ORDER BY CustomerID, BalanceStartDate
        
        END 

        --:: Load dbo.Fact_CustomerDailyBalance_NEW
        SET @SQL = ' 
 	    IF OBJECT_ID(''dbo.Fact_CustomerDailyBalance_NEW'',''U'') IS NOT NULL   DROP TABLE dbo.Fact_CustomerDailyBalance_NEW;
	    CREATE TABLE dbo.Fact_CustomerDailyBalance_NEW WITH ' + @CreateTableWith + ' AS
        WITH CTE_NEW AS
        (
            SELECT  CustomerID, 
                    BalanceStartDate, 
                    CONVERT(DATE,LEAD(DATEADD(DAY,-1,BalanceStartDate),1,''9999-12-31'') OVER (PARTITION BY CustomerID ORDER BY BalanceStartDate)) BalanceEndDate, 
                    TollTxnCount, TollAmount, CreditAmount, DebitAmount, CreditTxnCount, DebitTxnCount, 
                    BeginningBalanceAmount, EndingBalanceAmount, CalcEndingBalanceAmount, BalanceDiffAmount, 
                    BeginningCustTxnID, EndingCustTxnID, EDW_UpdateDate,
                    ROW_NUMBER() OVER (PARTITION BY CustomerID, BalanceStartDate ORDER BY EDW_UpdateDate DESC) RN
            FROM    
                    (
                        SELECT * FROM Stage.CustomerDailyBalanceWithActivity 
                        UNION               
                        SELECT * FROM ' + CASE WHEN @IsFullLoad = 1 THEN 'Stage.CustomerDailyBalanceWithNoActivity' ELSE 'Stage.CustomerDailyBalanceOpenEnded' END + '
                    ) S
        )
        SELECT  CustomerID,
                BalanceStartDate,
                BalanceEndDate,
                TollTxnCount,
                TollAmount,
                CreditAmount,
                DebitAmount,
                CreditTxnCount,
                DebitTxnCount,
                BeginningBalanceAmount,
                EndingBalanceAmount,
                CalcEndingBalanceAmount,
                BalanceDiffAmount,
                BeginningCustTxnID,
                EndingCustTxnID,
                EDW_UpdateDate
        FROM    CTE_NEW 

        WHERE   RN = 1
        OPTION  (LABEL = ''dbo.Fact_CustomerDailyBalance_NEW'');'

        IF @Trace_Flag = 1 EXEC Utility.LongPrint @SQL
        EXEC (@SQL)
       
	    SET  @Log_Message = 'Loaded dbo.Fact_CustomerDailyBalance_NEW'
        EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, -1

        IF @Trace_Flag = 1 SELECT TOP 100 'dbo.Fact_CustomerDailyBalance_NEW' SRC, * FROM dbo.Fact_CustomerDailyBalance_NEW ORDER BY CustomerID, BalanceStartDate

        --:: Full Load
	    IF @IsFullLoad = 1
	    BEGIN
            -- Create statistics and swap table for Full Load
		    CREATE STATISTICS STATS_FactCustomerDailyBalance_001 ON dbo.Fact_CustomerDailyBalance_NEW (CustomerID);
		    CREATE STATISTICS STATS_FactCustomerDailyBalance_002 ON dbo.Fact_CustomerDailyBalance_NEW (BalanceStartDate);
            CREATE STATISTICS STATS_FactCustomerDailyBalance_003 ON dbo.Fact_CustomerDailyBalance_NEW (BalanceEndDate);
            CREATE STATISTICS STATS_FactCustomerDailyBalance_004 ON dbo.Fact_CustomerDailyBalance_NEW (BeginningCustTxnID);
		    CREATE STATISTICS STATS_FactCustomerDailyBalance_005 ON dbo.Fact_CustomerDailyBalance_NEW (EndingCustTxnID);
       	    CREATE STATISTICS STATS_FactCustomerDailyBalance_006 ON dbo.Fact_CustomerDailyBalance_NEW (BeginningBalanceAmount);
            CREATE STATISTICS STATS_FactCustomerDailyBalance_007 ON dbo.Fact_CustomerDailyBalance_NEW (EndingBalanceAmount);
            CREATE STATISTICS STATS_FactCustomerDailyBalance_008 ON dbo.Fact_CustomerDailyBalance_NEW (TollTxnCount);
            CREATE STATISTICS STATS_FactCustomerDailyBalance_009 ON dbo.Fact_CustomerDailyBalance_NEW (TollAmount);

            -- Table swap!
		    EXEC Utility.TableSwap 'dbo.Fact_CustomerDailyBalance_NEW', 'dbo.Fact_CustomerDailyBalance' 

		    SET @Log_Message = 'Completed Full Load'
            EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
        END
	    ELSE
        --:: Incremental Daily Load
        BEGIN
            IF @Trace_Flag = 1 PRINT 'Calling: Utility.ManagePartitions_Date'
		    EXEC Utility.ManagePartitions_Date 'dbo.Fact_CustomerDailyBalance', 'Month'
            
            --:: Delete old rows from the main table
            DELETE dbo.Fact_CustomerDailyBalance
            WHERE EXISTS ( SELECT CustomerID 
                                FROM dbo.Fact_CustomerDailyBalance_NEW 
                            WHERE Fact_CustomerDailyBalance_NEW.CustomerID = Fact_CustomerDailyBalance.CustomerID 
                                AND Fact_CustomerDailyBalance_NEW.BalanceStartDate = Fact_CustomerDailyBalance.BalanceStartDate 
                            ) 
            EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Delete old rows from the main table dbo.Fact_CustomerDailyBalanceWithActivity', 'I', -1, NULL

            --:: Add new rows from _NEW table which has new and modified rows
            INSERT dbo.Fact_CustomerDailyBalance (CustomerID,BalanceStartDate,BalanceEndDate,TollTxnCount,TollAmount,CreditAmount,DebitAmount,CreditTxnCount,DebitTxnCount,BeginningBalanceAmount,EndingBalanceAmount,CalcEndingBalanceAmount,BalanceDiffAmount,BeginningCustTxnID,EndingCustTxnID,EDW_UpdateDate)
            SELECT CustomerID,BalanceStartDate,BalanceEndDate,TollTxnCount,TollAmount,CreditAmount,DebitAmount,CreditTxnCount,DebitTxnCount,BeginningBalanceAmount,EndingBalanceAmount,CalcEndingBalanceAmount,BalanceDiffAmount,BeginningCustTxnID,EndingCustTxnID,EDW_UpdateDate
                FROM dbo.Fact_CustomerDailyBalance_NEW
            
            EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Inserted new rows from _NEW table which has new and modified rows into the main table dbo.Fact_CustomerDailyBalanceWithActivity', 'I', -1, NULL

	        SET @SQL = 'UPDATE STATISTICS dbo.Fact_CustomerDailyBalance'
		    EXEC (@SQL)

            -- Log
		    SET @Log_Message = 'Completed Incremental Daily Load'
            EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', NULL, NULL
        END


        IF @Trace_Flag = 1 SELECT TOP 1000 'dbo.Fact_CustomerDailyBalance' SRC, * FROM dbo.Fact_CustomerDailyBalance ORDER BY CustomerID DESC, BalanceStartDate
        IF @Trace_Flag = 1 SELECT TOP 100  'Utility.ProcessLog' SRC, * FROM Utility.ProcessLog WHERE LogSource = 'dbo.Fact_CustomerDailyBalance_Load' AND LogDate >= @Log_Start_Date ORDER BY LogDate DESC


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

--:: Run SP
EXEC dbo.Fact_CustomerDailyBalance_Load @Load_Start_Date = NULL, @IsFullLoad = 1 -- Full Load
EXEC dbo.Fact_CustomerDailyBalance_Load @Load_Start_Date = NULL, @IsFullLoad = 0 -- Incremental Load
EXEC dbo.Fact_CustomerDailyBalance_Load @Load_Start_Date = '2023-11-01', @IsFullLoad = 0 -- Reload

SELECT TOP 100 * FROM Utility.ProcessLog WHERE LogSource = 'dbo.Fact_CustomerDailyBalance_Load' ORDER BY 1 DESC
SELECT TOP 100 'dbo.Fact_CustomerDailyBalance_Load' Table_Name, * FROM dbo.Fact_CustomerDailyBalance ORDER BY 1,2

-------------------------------------------------------------------------------------------------------------------

--:: Backup after the initial FULL LOAD
SELECT * INTO dbo.Fact_CustomerDailyBalance_NEW_BEFORE FROM dbo.Fact_CustomerDailyBalance_NEW -- BACKUP
SELECT * INTO dbo.Fact_CustomerDailyBalance_BEFORE FROM dbo.Fact_CustomerDailyBalance -- BACKUP
--:: Repeat test cycle.
TRUNCATE TABLE dbo.Fact_CustomerDailyBalance
INSERT dbo.Fact_CustomerDailyBalance
SELECT * FROM dbo.Fact_CustomerDailyBalance_BEFORE

-------------------------------------------------------------------------------------------------------------------

--:1: Full load - Analyze the final data source for the fact table load query
IF OBJECT_ID('stage.CustomerDailyBalance','U') IS NOT NULL    DROP TABLE stage.CustomerDailyBalance
CREATE TABLE stage.CustomerDailyBalance WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CustomerID), PARTITION (BalanceStartDate RANGE RIGHT FOR VALUES ('2021-01-01','2021-02-01','2021-03-01','2021-04-01','2021-05-01','2021-06-01','2021-07-01','2021-08-01','2021-09-01','2021-10-01','2021-11-01','2021-12-01','2022-01-01','2022-02-01','2022-03-01','2022-04-01','2022-05-01','2022-06-01','2022-07-01','2022-08-01','2022-09-01','2022-10-01','2022-11-01','2022-12-01','2023-01-01','2023-02-01','2023-03-01','2023-04-01','2023-05-01','2023-06-01','2023-07-01','2023-08-01','2023-09-01','2023-10-01','2023-11-01','2023-12-01'))) AS
SELECT CustomerID, BalanceStartDate, TollTxnCount, CreditAmount, DebitAmount, CreditTxnCount, DebitTxnCount, BeginningBalanceAmount, EndingBalanceAmount, CalcEndingBalanceAmount, BalanceDiffAmount, BeginningCustTxnID, EndingCustTxnID, EDW_UpdateDate
FROM Stage.CustomerDailyBalanceWithActivity 
UNION ALL 
SELECT CustomerID, BalanceStartDate, TollTxnCount, CreditAmount, DebitAmount, CreditTxnCount, DebitTxnCount, BeginningBalanceAmount, EndingBalanceAmount, CalcEndingBalanceAmount, BalanceDiffAmount, BeginningCustTxnID, EndingCustTxnID, EDW_UpdateDate
FROM Stage.CustomerDailyBalanceWithNoActivity
            
SELECT CustomerID, COUNT(DISTINCT BalanceStartDate) BalanceStartDate_Count
INTO #GT1
FROM stage.CustomerDailyBalance
GROUP BY CustomerID
HAVING COUNT(1) > 1
            
SELECT CustomerID, COUNT(DISTINCT BalanceStartDate) BalanceStartDate_Count
INTO #EQ1
FROM stage.CustomerDailyBalance
WHERE BalanceStartDate >= '2023-10-21'
GROUP BY CustomerID
HAVING COUNT(1) = 1
            
SELECT TOP 1000 * FROM #GT1  ORDER BY 1
SELECT TOP 1000 * FROM #EQ1  ORDER BY 1

SELECT TOP (100) 'dbo.Fact_CustomerDailyBalance_BEFORE' SRC, * FROM dbo.Fact_CustomerDailyBalance_BEFORE ORDER BY 2,3
SELECT TOP (100) 'Stage.CustomerDailyBalanceWithActivity' SRC, * FROM Stage.CustomerDailyBalanceWithActivity ORDER BY 2,3
SELECT TOP (100) 'Stage.CustomerDailyBalanceWithNoActivity' SRC, * FROM Stage.CustomerDailyBalanceWithNoActivity ORDER BY 2,3
SELECT TOP (100) 'stage.CustomerDailyBalance' SRC, * FROM stage.CustomerDailyBalance ORDER BY 2,3

-------------------------------------------------------------------------------------------------------------------

--:2: Daily incremental load - Analyze the final data source for the fact table load query 
IF OBJECT_ID('stage.CustomerDailyBalance','U') IS NOT NULL    DROP TABLE stage.CustomerDailyBalance
CREATE TABLE stage.CustomerDailyBalance WITH(CLUSTERED INDEX (CustomerID), DISTRIBUTION = HASH(CustomerID)) AS 
SELECT * FROM Stage.CustomerDailyBalanceWithActivity 
UNION ALL                    
SELECT * FROM Stage.CustomerDailyBalanceOpenEnded

SELECT TOP (100) 'dbo.Fact_CustomerDailyBalance' SRC, * FROM dbo.Fact_CustomerDailyBalance ORDER BY 2,3
SELECT TOP (100) 'dbo.Fact_CustomerDailyBalance_NEW' SRC, * FROM dbo.Fact_CustomerDailyBalance_NEW ORDER BY CustomerID, BalanceStartDate
SELECT TOP (100) 'Stage.CustomerDailyBalanceWithActivity' SRC, * FROM Stage.CustomerDailyBalanceWithActivity ORDER BY 2,3
SELECT TOP (100) 'Stage.CustomerDailyBalanceOpenEnded' SRC, * FROM Stage.CustomerDailyBalanceOpenEnded ORDER BY 2,3
SELECT TOP (100) 'stage.CustomerDailyBalance' SRC, * FROM stage.CustomerDailyBalance ORDER BY 2,3

--===============================================================================================================
--:: Data profiling
--===============================================================================================================

--:: TP_CustTxns data profiling. Old PostedDate rows inserted today are a common feature.
SELECT LND_UpdateDate, CONVERT(DATE,PostedDate) PostedDate, MIN(PostedDate) MIN_PostedDate, MAX(PostedDate) MAX_PostedDate, COUNT(1) RC
FROM LND_TBOS.TollPlus.TP_CustTxns
WHERE LND_UpdateDate > '11/20/2023'
GROUP BY LND_UpdateDate, CONVERT(DATE,PostedDate)
ORDER BY 1,2 DESC

--:: Reload start date
SELECT MIN(PostedDate)
FROM
(
SELECT LND_UpdateDate, CONVERT(DATE,PostedDate) PostedDate, MIN(PostedDate) MIN_PostedDate, MAX(PostedDate) MAX_PostedDate, COUNT(1) RC
FROM LND_TBOS.TollPlus.TP_CustTxns
WHERE LND_UpdateDate > '11/20/2023' -- @Fact_Max_BalanceStartDate
GROUP BY LND_UpdateDate, CONVERT(DATE,PostedDate)
)T
ORDER BY 1,2 DESC

--:: TP_CustTxns Deleted rows data profiling
SELECT LND_UpdateDate, LND_UpdateType, COUNT(DISTINCT CONVERT(DATE,PostedDate)) PostedDate_Count, CONVERT(DATE,MIN(PostedDate)) MIN_PostedDate, CONVERT(DATE,MAX(PostedDate)) MAX_PostedDate, COUNT(1) Del_RC
FROM LND_TBOS.TollPlus.TP_CustTxns
WHERE LND_UpdateDate > '1/1/2023'  
AND LND_UpdateType = 'D'
GROUP BY LND_UpdateDate, LND_UpdateType
ORDER BY LND_UpdateDate DESC

--:: CustomerID, PostedDate is not unique in TP_CustTxns.
SELECT  CustomerID, PostedDate, COUNT(1) RC
FROM    LND_TBOS.TollPlus.TP_CustTxns  
WHERE   BalanceType = 'TollBal'
        AND AppTxnTypeCode NOT LIKE '%FAIL%' 
        AND LND_UpdateType <> 'D'
        AND PostedDate>='1/1/2021'
GROUP BY CustomerID, PostedDate
HAVING COUNT(1) > 1

--:: 5295232 TagStore Cust in dim_customer
SELECT COUNT(1) TagStore_CustCount
FROM dbo.Dim_Customer C 
WHERE AccountCategoryDesc = 'TagStore'

--:: 4151868 cust with some activity after 1/1/2021.
SELECT DISTINCT CustomerID FROM dbo.Fact_CustomerDailyBalance WHERE BalanceStartDate > '1/1/2021'

--:: 8104188 rows per day, 1254074 distinct cust count per day
SELECT  COUNT(1) CustTxn_RowCount, COUNT(DISTINCT CustomerID) Distinct_CustCount
FROM    LND_TBOS.TollPlus.TP_CustTxns
WHERE   LND_UpdateDate > '12/6/2023'

--===============================================================================================================
-- dbo.Fact_CustomerDailyBalance data validations 
--===============================================================================================================

--:: Balance Continuity check. 434 accounts have diff when comparing current day beginning bal with previous day ending bal.
SELECT *
FROM
(
    SELECT CustomerID,
           BalanceStartDate,
           BalanceEndDate,
           BeginningBalanceAmount,
           EndingBalanceAmount,
           LAG(EndingBalanceAmount) OVER (partition BY CustomerID ORDER BY BalanceStartDate) PrevEndingBal,
           BeginningBalanceAmount - LAG(EndingBalanceAmount) OVER (PARTITION BY CustomerID ORDER BY BalanceStartDate) Diff
    FROM dbo.Fact_CustomerDailyBalance
) t
WHERE Diff <> 0
ORDER BY CustomerID, BalanceStartDate;

--:: Daily Balance data integrity check. 282 accounts have diff within the span of a day (beginning bal + total credits + total debits <> ending bal).  
SELECT  * 
FROM    dbo.Fact_CustomerDailyBalance 			
WHERE   BalanceDiffAmount <> 0			
ORDER BY 2 DESC	

--===============================================================================================================
-- DYNAMIC SQL
--===============================================================================================================

--:: Full Load
IF OBJECT_ID('dbo.Fact_CustomerDailyBalance_NEW','U') IS NOT NULL   DROP TABLE dbo.Fact_CustomerDailyBalance_NEW;
CREATE TABLE dbo.Fact_CustomerDailyBalance_NEW WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CustomerID), PARTITION (BalanceStartDate RANGE RIGHT FOR VALUES ('2021-01-01','2021-02-01','2021-03-01','2021-04-01','2021-05-01','2021-06-01','2021-07-01','2021-08-01','2021-09-01','2021-10-01','2021-11-01','2021-12-01','2022-01-01','2022-02-01','2022-03-01','2022-04-01','2022-05-01','2022-06-01','2022-07-01','2022-08-01','2022-09-01','2022-10-01','2022-11-01','2022-12-01','2023-01-01','2023-02-01','2023-03-01','2023-04-01','2023-05-01','2023-06-01','2023-07-01','2023-08-01','2023-09-01','2023-10-01','2023-11-01','2023-12-01'))) AS
WITH CTE_NEW AS
(
    SELECT  CustomerID, 
            BalanceStartDate, 
            CONVERT(DATE,LEAD(DATEADD(DAY,-1,BalanceStartDate),1,'9999-12-31') OVER (PARTITION BY CustomerID ORDER BY BalanceStartDate)) BalanceEndDate, 
            TollTxnCount, TollAmount, CreditAmount, DebitAmount, CreditTxnCount, DebitTxnCount, 
            BeginningBalanceAmount, EndingBalanceAmount, CalcEndingBalanceAmount, BalanceDiffAmount, 
            BeginningCustTxnID, EndingCustTxnID, EDW_UpdateDate,
            ROW_NUMBER() OVER (PARTITION BY CustomerID, BalanceStartDate ORDER BY EDW_UpdateDate DESC) RN
    FROM    
            (
                SELECT * FROM Stage.CustomerDailyBalanceWithActivity 
                UNION               
                SELECT * FROM Stage.CustomerDailyBalanceWithNoActivity
            ) S
)
SELECT  CustomerID,
        BalanceStartDate,
        BalanceEndDate,
        TollTxnCount,
        TollAmount,
        CreditAmount,
        DebitAmount,
        CreditTxnCount,
        DebitTxnCount,
        BeginningBalanceAmount,
        EndingBalanceAmount,
        CalcEndingBalanceAmount,
        BalanceDiffAmount,
        BeginningCustTxnID,
        EndingCustTxnID,
        EDW_UpdateDate
FROM    CTE_NEW 

WHERE   RN = 1
OPTION  (LABEL = 'dbo.Fact_CustomerDailyBalance_NEW');

--:: Incremental
IF OBJECT_ID('dbo.Fact_CustomerDailyBalance_NEW','U') IS NOT NULL   DROP TABLE dbo.Fact_CustomerDailyBalance_NEW;
CREATE TABLE dbo.Fact_CustomerDailyBalance_NEW WITH (CLUSTERED INDEX (CustomerID), DISTRIBUTION = HASH(CustomerID)) AS
WITH CTE_NEW AS
(
    SELECT  CustomerID, 
            BalanceStartDate, 
            CONVERT(DATE,LEAD(DATEADD(DAY,-1,BalanceStartDate),1,'9999-12-31') OVER (PARTITION BY CustomerID ORDER BY BalanceStartDate)) BalanceEndDate, 
            TollTxnCount, TollAmount, CreditAmount, DebitAmount, CreditTxnCount, DebitTxnCount, 
            BeginningBalanceAmount, EndingBalanceAmount, CalcEndingBalanceAmount, BalanceDiffAmount, 
            BeginningCustTxnID, EndingCustTxnID, EDW_UpdateDate,
            ROW_NUMBER() OVER (PARTITION BY CustomerID, BalanceStartDate ORDER BY EDW_UpdateDate DESC) RN
    FROM    
            (
                SELECT * FROM Stage.CustomerDailyBalanceWithActivity 
                UNION               
                SELECT * FROM Stage.CustomerDailyBalanceOpenEnded
            ) S
)
SELECT  CustomerID,
        BalanceStartDate,
        BalanceEndDate,
        TollTxnCount,
        TollAmount,
        CreditAmount,
        DebitAmount,
        CreditTxnCount,
        DebitTxnCount,
        BeginningBalanceAmount,
        EndingBalanceAmount,
        CalcEndingBalanceAmount,
        BalanceDiffAmount,
        BeginningCustTxnID,
        EndingCustTxnID,
        EDW_UpdateDate
FROM    CTE_NEW 

WHERE   RN = 1
OPTION  (LABEL = 'dbo.Fact_CustomerDailyBalance_NEW');

*/
