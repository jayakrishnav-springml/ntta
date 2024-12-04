CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_CustomerBalanceSnapshot_Load`(load_start_date DATE)
BEGIN
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
    DECLARE trace_flag INT64 DEFAULT 0;
    DECLARE log_message STRING;
    DECLARE lastpartitionid INT64;
    DECLARE partition_ranges STRING;
    BEGIN
      -- Debug
      -- DECLARE @Load_Start_Date [DATE] = NULL

      DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_CustomerBalanceSnapshot_Load';
      DECLARE main_table_name STRING DEFAULT 'EDW_TRIPS.Fact_CustomerBalanceSnapshot';
      DECLARE stagetablename STRING DEFAULT 'EDW_TRIPS.Fact_CustomerBalanceSnapshot_NEW';
      DECLARE log_start_date DATETIME;
      DECLARE sql STRING;
      DECLARE sql1 STRING;
      DECLARE startdate DATETIME;
      DECLARE enddate DATETIME;
      DECLARE snapshotmonthid INT64;
      SET log_start_date = current_datetime('America/Chicago');
      SET startdate = date_add(last_day(date_add(coalesce(CAST(load_start_date as DATETIME), current_datetime()),interval -2 month)), interval 1 DAY);
      SET enddate = datetime_sub(CAST(date_add(last_day(date_add(coalesce(CAST(load_start_date as DATETIME), current_datetime()),interval -1 month)), interval 1 DAY) as DATETIME), interval 2 MILLISECOND);
      SET snapshotmonthid = CAST(substr(CAST(FORMAT_DATE("%Y%m%d", enddate) as STRING), 1, 6) as INT64);
      IF trace_flag = 1 THEN
        SELECT
            startdate AS startdate,
            enddate AS enddate,
            snapshotmonthid AS snapshotmonthid
        ;
      END IF;
      SET log_message = concat('Started load for partition ', substr(CAST(snapshotmonthid as STRING), 1, 10), ' from ', substr(CAST(FORMAT_DATE("%Y-%m-%d %H:%M:%E3S", startdate) as STRING), 1, 19), ' to ', substr(CAST(FORMAT_DATETIME('%Y-%m-%d %H:%M:%E3S',enddate) as STRING), 1, 19));
      IF trace_flag = 1 THEN
        --SELECT log_message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      
      --=============================================================================================================
      -- Load dbo.Fact_CustomerBalanceSnapshot        
      --=============================================================================================================
	
      SET lastpartitionid = CAST(substr(CAST(FORMAT_DATE("%Y%m%d",date_add (last_day(date_add(Log_Start_Date,interval 1 month)), interval 1 DAY)) as STRING), 1, 6) as INT64);
      --CALL EDW_TRIPS_SUPPORT.Get_PartitionMonthIDRange_String(substr(CAST(202101 as STRING), 1, 10), substr(CAST(lastpartitionid as STRING), 1, 10), partition_ranges);
      IF trace_flag = 1 THEN
        --SELECT concate('Calling: Utility.Get_PartitionMonthIDRange_String from 202101 till ' + CAST(LastPartitionID AS string) + ': ' + Partition_Ranges);
      END IF;
      IF (
        (SELECT COUNT(1) 
        FROM `EDW_TRIPS.INFORMATION_SCHEMA.TABLES` 
        WHERE lower(table_name) = lower(SUBSTR(main_table_name,STRPOS(main_table_name,'.')+1))) = 0
      ) THEN
        SET stagetablename = main_table_name;
      END IF;
      --DROP TABLE IF EXISTS EDW_TRIPS_STAGE.CustomerBalanceWithActivity;
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.CustomerBalanceWithActivity
        AS
          SELECT
              coalesce(cts.snapshotmonthid, -1) AS snapshotmonthid,
              coalesce(CAST( cts.customerid as INT64), -1) AS customerid,
              DATE(enddate) AS balancedate,
              coalesce(cts.tolltxncount, 0) AS tolltxncount,
              coalesce(CAST(cts.creditamount as NUMERIC), CAST(0 as NUMERIC)) AS creditamount,
              coalesce(CAST(cts.debitamount as NUMERIC), CAST(0 as NUMERIC)) AS debitamount,
              coalesce(cts.credittxncount, 0) AS credittxncount,
              coalesce(cts.debittxncount, 0) AS debittxncount,
              coalesce(CAST( bb.previousbalance as NUMERIC), CAST(0 as NUMERIC)) AS beginningbalanceamount,
              coalesce(CAST( eb.currentbalance as NUMERIC), CAST(0 as NUMERIC)) AS endingbalanceamount,
              coalesce(CAST(bb.previousbalance + cts.creditamount + cts.debitamount as NUMERIC), CAST(0 as NUMERIC)) AS calcendingbalanceamount,
              coalesce(CAST(eb.currentbalance - (bb.previousbalance + cts.creditamount + cts.debitamount) as NUMERIC), CAST(0 as NUMERIC)) AS balancediffamount,
              cts.beginningcusttxnid,
              cts.endingcusttxnid,
              current_datetime() AS edw_updatedate
            FROM
              (
                SELECT
                    CAST(left(CAST( FORMAT_DATE("%Y%m%d",posteddate) as STRING), 6) as INT64) AS snapshotmonthid,
                    ct.customerid,
                    sum(CASE
                      WHEN ct.linksourcename = 'TOLLPLUS.TP_CUSTOMERTRIPS' THEN 1
                      ELSE 0
                    END) AS tolltxncount,
                    sum(CASE
                      WHEN ct.txnamount < 0 THEN ct.txnamount
                      ELSE 0
                    END) AS debitamount,
                    sum(CASE
                      WHEN ct.txnamount > 0 THEN ct.txnamount
                      ELSE 0
                    END) AS creditamount,
                    sum(CASE
                      WHEN ct.txnamount < 0 THEN 1
                      ELSE 0
                    END) AS credittxncount,
                    sum(CASE
                      WHEN ct.txnamount > 0 THEN 1
                      ELSE 0
                    END) AS debittxncount,
                    min(ct.custtxnid) AS beginningcusttxnid,
                    max(ct.custtxnid) AS endingcusttxnid
                  FROM
                    LND_TBOS.TollPlus_TP_CustTxns AS ct
                    INNER JOIN LND_TBOS.TollPlus_TP_Customer_Plans AS cp ON cp.customerid = ct.customerid
                     AND ct.lnd_updatetype <> 'D'
                  WHERE cp.planid = 3
                   AND ct.posteddate BETWEEN startdate AND enddate
                   AND ct.balancetype = 'TollBal'
                   AND ct.apptxntypecode NOT LIKE '%FAIL%'
                   --AND  ct.CustomerID = 4007342
                  GROUP BY ct.customerid, snapshotmonthid
              ) AS cts
              INNER JOIN LND_TBOS.TollPlus_TP_CustTxns AS bb ON bb.custtxnid = cts.beginningcusttxnid
              INNER JOIN LND_TBOS.TollPlus_TP_CustTxns AS eb ON eb.custtxnid = cts.endingcusttxnid
      ;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Loaded Stage.CustomerBalanceWithActivity', 'I', -1, CAST(NULL as STRING));
      --DROP TABLE IF EXISTS EDW_TRIPS_STAGE.CustomerBalanceWithNoActivity;
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.CustomerBalanceWithNoActivity
        AS
          (SELECT
              coalesce(snapshotmonthid, -1) AS snapshotmonthid,
              coalesce(CAST( cts.customerid as INT64), -1) AS customerid,
              DATE(enddate) AS balancedate,
              coalesce(0, 0) AS tolltxncount,
              coalesce(CAST(0 as NUMERIC), CAST(0 as NUMERIC)) AS creditamount,
              coalesce(CAST(0 as NUMERIC), CAST(0 as NUMERIC)) AS debitamount,
              coalesce(0, 0) AS credittxncount,
              coalesce(0, 0) AS debittxncount,
              coalesce(CAST( eb.currentbalance as NUMERIC), CAST(0 as NUMERIC)) AS beginningbalanceamount,
              coalesce(CAST( eb.currentbalance as NUMERIC), CAST(0 as NUMERIC)) AS endingbalanceamount,
              coalesce(CAST( eb.currentbalance as NUMERIC), CAST(0 as NUMERIC)) AS calcendingbalanceamount,
              coalesce(CAST(0 as NUMERIC), CAST(0 as NUMERIC)) AS balancediffamount,
              coalesce(0, 0) AS beginningcusttxnid,
              cts.lastcusttxnid AS endingcusttxnid,
              current_datetime() AS edw_updatedate
            FROM
              (
                SELECT
                    ct.customerid,
                    max(ct.posteddate) AS lastposteddate,
                    max(ct.custtxnid) AS lastcusttxnid
                  FROM
                    LND_TBOS.TollPlus_TP_CustTxns AS ct
                    INNER JOIN LND_TBOS.TollPlus_TP_Customer_Plans AS cp ON cp.customerid = ct.customerid
                     AND ct.lnd_updatetype <> 'D'
                  WHERE cp.planid = 3
                   AND ct.posteddate < startdate
                   AND ct.balancetype = 'TollBal'
                   AND apptxntypecode NOT LIKE '%FAIL%'
                   AND NOT EXISTS (
                    SELECT
                        1
                      FROM
                        EDW_TRIPS_STAGE.CustomerBalanceWithActivity AS aeb
                      WHERE ct.customerid = aeb.customerid
                  )
                  GROUP BY ct.customerid
              ) AS cts
              INNER JOIN LND_TBOS.TollPlus_TP_CustTxns AS eb ON eb.custtxnid = cts.lastcusttxnid)
      ;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Loaded Stage.CustomerBalanceWithNoActivity', 'I', -1, CAST(NULL as STRING));
      -- SET sql = concat(' \r\n\t     IF OBJECT_ID(\'', stagetablename, '\',\'U\') IS NOT NULL    DROP TABLE ', stagetablename, ';\r\n\t     CREATE TABLE ', stagetablename, ' WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CustomerID), PARTITION (SnapshotMonthID RANGE RIGHT FOR VALUES (', partition_ranges, '))) AS\r\n\t     SELECT * FROM Stage.CustomerBalanceWithActivity  \r\n         UNION ALL \r\n         SELECT * FROM Stage.CustomerBalanceWithNoActivity\r\n\t     OPTION (LABEL = \'dbo.Fact_CustomerBalanceSnapshot_NEW\');');
      --SET sql = concat('DROP TABLE IF EXISTS ', stagetablename);
      --EXECUTE IMMEDIATE sql;
      SET sql =concat('CREATE OR REPLACE TABLE ', stagetablename,' AS SELECT * FROM EDW_TRIPS_STAGE.CustomerBalanceWithActivity UNION ALL SELECT * FROM EDW_TRIPS_STAGE.CustomerBalanceWithNoActivity');
      EXECUTE IMMEDIATE sql;
      --Log
      SET log_message = concat('Loaded ', stagetablename);
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, sql);
      IF stagetablename = main_table_name THEN
      ELSE
        IF trace_flag = 1 THEN
          --SELECT 'Calling: Utility.ManagePartitions_DateID';
        END IF;
        IF trace_flag = 1 THEN
          --SELECT 'Calling: Utility.PartitionSwitch_Snapshot';
        END IF;
        --CALL EDW_TRIPS_SUPPORT.ManagePartitions_DateID(main_table_name, 'MonthID:Month');
        -- commented PartitionSwitch_Snapshot and implemented this logic using DELETE and INSERT STATEMENTS below
        --CALL EDW_TRIPS_SUPPORT.PartitionSwitch_Snapshot('EDW_TRIPS.Fact_CustomerBalanceSnapshot_NEW', main_table_name);
        --IF OBJECT_ID('dbo.Fact_CustomerBalanceSnapshot_NEW') IS NOT NULL DROP TABLE dbo.Fact_CustomerBalanceSnapshot_NEW
        
        -- Dropping Records From Main Table having common snapshotmonthid values with Stage Table.
        SET sql1 = concat("Delete From ", main_table_name , " where snapshotmonthid In ( Select snapshotmonthid  from ",stagetablename , " )" );
        EXECUTE IMMEDIATE sql1;
        
        -- Inserting NEW Records from Stage to Main Table
        SET sql1 = concat("Insert Into  ", main_table_name , " Select * from ",stagetablename );
        EXECUTE IMMEDIATE sql1;
      END IF;
      -- Log
      SET log_message = concat('Finished load for partition ', substr(CAST(snapshotmonthid as STRING), 1, 10));
      IF trace_flag = 1 THEN
        --SELECT log_message;
      END IF;
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message; -- Rethrow the error!
      END;
    END;
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



  END;