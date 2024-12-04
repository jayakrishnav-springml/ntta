CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_CustomerDailyBalance_Load`(load_start_date DATE, isfullload INT64)
BEGIN
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
    DECLARE firstbalanceloaddate DATE DEFAULT '2021-01-01';
    DECLARE balancestartdate DATE;
    DECLARE fact_max_balancestartdate DATE;
    DECLARE lnd_dataasofdate DATETIME;
    DECLARE balanceenddate DATE;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    DECLARE firstpartitiondate DATE DEFAULT '2020-12-01';
    DECLARE lastpartitiondate DATE;
    DECLARE partition_ranges STRING;
    DECLARE createtablewith STRING;
    DECLARE sql STRING;
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_CustomerDailyBalance_Load';
    DECLARE log_start_date DATETIME DEFAULT current_datetime('America/Chicago');
    BEGIN
		-- DEBUG
		-- DECLARE @Load_Start_Date DATE = NULL, @IsFullLoad BIT = 1 -- Round 1. New. Full Load
		-- DECLARE @Load_Start_Date DATE = NULL, @IsFullLoad BIT = 0 -- Round 2. Incr. 2023-11-01 load.
		-- DECLARE @Load_Start_Date DATE = '2023-10-25', @IsFullLoad BIT = 0 -- Round 2. Incr. 2023-10-25 reload.
		-- DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_CustomerDailyBalance_Load';
		-- DECLARE log_start_date DATETIME DEFAULT current_datetime();

		--=============================================================================================================
		--Get BalanceStartDate and BalanceEndDate for the current run
		--=============================================================================================================

		--:: BalanceStartDate
		IF (SELECT count(1) FROM  EDW_TRIPS.INFORMATION_SCHEMA.TABLES WHERE table_name='Fact_CustomerDailyBalance') = 0
		OR isfullload = 1 
		THEN
			SET  isfullload = 1;
			SET  balancestartdate = firstbalanceloaddate;
			/*Testing. Round 1 value: '2023-10-21'  Prod value: @FirstBalanceLoadDate*/
		ELSEIF load_start_date IS NULL THEN
			SET (balancestartdate , fact_max_balancestartdate ) = ( SELECT as Struct date_add(max(balancestartdate), interval 1 DAY) , max(balancestartdate) FROM EDW_TRIPS.Fact_CustomerDailyBalance where balancestartdate is not null  );
		ELSE
			set balancestartdate= load_start_date;
		END IF;

			Select isfullload  ,  balancestartdate  , fact_max_balancestartdate;
		
		--:: Daily incremental load. TP_CustTxns data received thru CDC for the last 24 hours can have rows with PostedDate older than last 24 hours. Reload the fact table from the min PostedDate onwards.
		IF isfullload = 0 
		THEN	
			select load_start_date,fact_max_balancestartdate;
			CREATE OR REPLACE TEMPORARY TABLE _SESSION.cte_sd AS (
				SELECT
					TollPlus_tp_custtxns.lnd_updatedate,
					CAST(TollPlus_tp_custtxns.posteddate as DATE) AS posteddate,
					min(TollPlus_tp_custtxns.posteddate) AS min_posteddate,
					max(TollPlus_tp_custtxns.posteddate) AS max_posteddate,
					count(1) AS rc
					FROM
					LND_TBOS.TollPlus_TP_CustTxns
					WHERE TollPlus_tp_custtxns.lnd_updatedate > coalesce(fact_max_balancestartdate, load_start_date)
					GROUP BY lnd_updatedate, posteddate
				);
			SET balancestartdate = ( SELECT coalesce(min(cte_sd.posteddate), firstbalanceloaddate) FROM cte_sd );
		END IF;
		select balancestartdate;
		
		--:: BalanceEndDate
		Set lnd_dataasofdate = ( SELECT max(TollPlus_tp_custtxns.posteddate) FROM LND_TBOS.TollPlus_TP_CustTxns ); -- where  posteddate < '2024-02-02T00:00:00'
			--WHERE   PostedDate < '2023-11-02 00:00' /*Testing: Simulate controlled full load and incremental load data. Comment in Prod*/ 
		SET balanceenddate = ( SELECT
									CASE
										WHEN TIME_TRUNC(time(lnd_dataasofdate), SECOND) = '23:59:59'
											THEN DATE(lnd_dataasofdate)
										ELSE 
											DATE(datetime_sub(lnd_dataasofdate, interval 1 DAY))
									END ) ;
	
		select balanceenddate , lnd_dataasofdate ;
		-- --> How can BalanceStartDate be after BalanceEndDate? Result: No output from this run.
		IF balancestartdate > balanceenddate 
		THEN
			SET log_message = concat('Attention! Balance Start Date ', coalesce(substr(CAST(balancestartdate as STRING), 1, 30), r'???'), ' is after Balance End Date ', coalesce(substr(CAST(balanceenddate as STRING), 1, 30), r'???'), coalesce(concat('! LND data "as of date" ', substr(CAST(lnd_dataasofdate as STRING), 1, 30)), ''), ' Result: No output from this run.');
			IF trace_flag = 1 THEN
				-- BigQuery does not support any equivalent for PRINT or LOG.
				select log_message;
        	END IF;
			CALL  EDW_TRIPS_SUPPORT.ToLog (log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
		END IF;

		-- --> BalanceStartDate cannot be more than 1 day prior to "data as of date". Result: No output from this run. 
		IF balancestartdate > lnd_dataasofdate OR balanceenddate > lnd_dataasofdate 
		THEN
			SET log_message = concat('Attention! Balance Start Date ', coalesce(substr(CAST(balancestartdate as STRING), 1, 30), r'???'), ' or Balance End Date ', coalesce(substr(CAST(balanceenddate as STRING), 1, 30), r'???'), ' is after LND data "as of date" ', coalesce(substr(CAST(lnd_dataasofdate as STRING), 1, 30), r'???'), '! Result: No output from this run.');
			IF trace_flag = 1 THEN
					-- BigQuery does not support any equivalent for PRINT or LOG.
					select log_message;
				END IF;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));	
		END IF;
		----:: Balance load dates table. Driving input all three modes of run: Full load, Daily incremental load, On demand load from a start date.
		DROP TABLE IF EXISTS _SESSION.balancedate;
		CREATE TEMPORARY TABLE _SESSION.balancedate
			AS
			SELECT
				dim_day.daydate AS balancestartdate,
				datetime_sub(datetime_add(SAFE_CAST(CAST(/* expression of unknown or erroneous type */ dim_day.daydate as STRING) AS DATETIME), interval 1 DAY), interval 2 MILLISECOND) AS balanceenddate
				FROM
				EDW_TRIPS.Dim_Day
				WHERE dim_day.daydate BETWEEN balancestartdate AND balanceenddate;

		IF trace_flag = 1 THEN
			SELECT
			'_SESSION.balancedate' AS src,
			_SESSION.balancedate.*
			FROM _SESSION.balancedate
			ORDER BY balancestartdate DESC ;
		END IF;
      
		SET lastpartitiondate = DATE_ADD(LAST_DAY(DATE_ADD(balanceenddate, INTERVAL 1 MONTH)),INTERVAL 1 DAY);
		IF trace_flag = 1 THEN
        	SELECT
            load_start_date AS load_start_date,
            lnd_dataasofdate AS lnd_dataasofdate,
            fact_max_balancestartdate AS fact_max_balancestartdate,
            balancestartdate AS balancestartdate,
            balanceenddate AS balanceenddate,
            firstbalanceloaddate AS firstbalanceloaddate,
            firstpartitiondate AS firstpartitiondate,
            lastpartitiondate AS lastpartitiondate
        ;
      	END IF;
		IF isfullload = 1 THEN
			-- CALL EDW_TRIPS_SUPPORT.Get_PartitionDateRange_String(substr(CAST(firstpartitiondate as STRING), 1, 10), substr(CAST(lastpartitiondate as STRING), 1, 10), partition_ranges);
			-- SET createtablewith = concat('(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH(CustomerID), PARTITION (BalanceStartDate RANGE RIGHT FOR VALUES (', partition_ranges, ')))');
			SET createtablewith="PARTITION BY DATE_TRUNC(balancestartdate, MONTH) OPTIONS ( require_partition_filter = False) ";
			SET log_message = concat('Started Full Load from BalanceStartDate ', coalesce(substr(CAST(balancestartdate as STRING), 1, 30), r'???'), ' to BalanceEndDate ', coalesce(substr(CAST(balanceenddate as STRING), 1, 30), r'???'), '. @LND_DataAsOfDate: ', coalesce(substr(CAST(lnd_dataasofdate as STRING), 1, 30), r'???'), '. @FirstBalanceLoadDate: ', coalesce(substr(CAST(firstbalanceloaddate as STRING), 1, 30), r'???'));
			IF trace_flag = 1 THEN
				select concat(log_message,'. CreateTableWith: ',createtablewith);
				-- BigQuery does not support any equivalent for PRINT or LOG.
			END IF;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
			
		ELSE
			-- SET createtablewith = '(CLUSTERED INDEX (CustomerID), DISTRIBUTION = HASH(CustomerID))';
			-- We can not Replace Clusterd Table with PARTITION , To avoid error during Full & Incremtnal Load Made it Generic 
			--SET createtablewith = "CLUSTER BY CustomerID";
			SET createtablewith="PARTITION BY DATE_TRUNC(balancestartdate, MONTH) OPTIONS ( require_partition_filter = False) ";
			SET log_message = concat('Started Incremental Load from BalanceStartDate ', coalesce(substr(CAST(balancestartdate as STRING), 1, 30), r'???'), ' to BalanceEndDate ', coalesce(substr(CAST(balanceenddate as STRING), 1, 30), r'???'), '. @Load_Start_Date: ', coalesce(substr(CAST(load_start_date as STRING), 1, 30), r'???'), ' & @Fact_Max_BalanceStartDate (both can determine BalanceStartDate based on MIN(PostedDate) in TollPlus_TP_CustTxns table having LND_UpdateDate > @Fact_Max_BalanceStartDate or @Load_Start_Date): ', coalesce(substr(CAST(fact_max_balancestartdate as STRING), 1, 30), r'???'), '. @LND_DataAsOfDate (determines BalanceEndDate): ', coalesce(substr(CAST(lnd_dataasofdate as STRING), 1, 30), r'???'));
			IF trace_flag = 1 THEN
				select concat(log_message,'. CreateTableWith: ',createtablewith);
				-- BigQuery does not support any equivalent for PRINT or LOG.
			END IF;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
				
		END IF;
      
		--=============================================================================================================
	    -- Load dbo.Fact_CustomerBalanceSnapshot        
	    --=============================================================================================================

        -- Insert a new record into the stage history table with Activity on a given Date
		CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.CustomerDailyBalanceWithActivity
		CLUSTER BY CustomerID
			AS
			SELECT
				coalesce(CAST(cts.customerid as INT64), -1) AS customerid,
				CAST( bb.posteddate as DATE) AS balancestartdate,
				coalesce(cts.tolltxncount, 0) AS tolltxncount,
				coalesce(CAST(cts.tollamount as NUMERIC), CAST(0 as NUMERIC)) AS tollamount,
				coalesce(CAST(cts.creditamount as NUMERIC), CAST(0 as NUMERIC)) AS creditamount,
				coalesce(CAST(cts.debitamount as NUMERIC), CAST(0 as NUMERIC)) AS debitamount,
				coalesce(cts.credittxncount, 0) AS credittxncount,
				coalesce(cts.debittxncount, 0) AS debittxncount,
				coalesce(CAST( bb.previousbalance as NUMERIC), CAST(0 as NUMERIC)) AS beginningbalanceamount,
				coalesce(CAST(eb.currentbalance as NUMERIC), CAST(0 as NUMERIC)) AS endingbalanceamount,
				coalesce(CAST(bb.previousbalance + cts.creditamount + cts.debitamount as NUMERIC), CAST(0 as NUMERIC)) AS calcendingbalanceamount,
				coalesce(CAST(eb.currentbalance - (bb.previousbalance + cts.creditamount + cts.debitamount) as NUMERIC), CAST(0 as NUMERIC)) AS balancediffamount,
				cts.beginningcusttxnid AS beginningcusttxnid,
				cts.endingcusttxnid AS endingcusttxnid,
				coalesce(current_datetime() , DATETIME '1900-01-01 00:00:00') AS edw_updatedate
				FROM
				(
					SELECT
						ct.customerid,
						substr(CAST( format_timestamp("%Y-%m-%d",CT.PostedDate) as STRING),1,10) AS posteddate,
						sum(CASE
						WHEN ct.linksourcename = 'TOLLPLUS.TP_CUSTOMERTRIPS' THEN 1
						ELSE 0
						END) AS tolltxncount,
						sum(CASE
						WHEN ct.linksourcename = 'TOLLPLUS.TP_CUSTOMERTRIPS' THEN ct.txnamount * -1
						ELSE 0
						END) AS tollamount,
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
						END) AS debittxncount,
						sum(CASE
						WHEN ct.txnamount > 0 THEN 1
						ELSE 0
						END) AS credittxncount,
						min(ct.custtxnid) AS beginningcusttxnid,
						max(ct.custtxnid) AS endingcusttxnid
					FROM
						EDW_TRIPS.Dim_Customer AS c
						INNER JOIN LND_TBOS.TollPlus_TP_CustTxns AS ct ON ct.customerid = c.customerid
						AND c.accountcategorydesc = 'TagStore'
						AND ct.lnd_updatetype <> 'D'  
						INNER JOIN balancedate AS bd ON bd.balancestartdate = CAST(substr(CAST( format_timestamp("%Y-%m-%d",CT.PostedDate) as STRING),1,10)AS DATE)
					WHERE ct.balancetype = 'TollBal'
					AND ct.apptxntypecode NOT LIKE '%FAIL%'
					GROUP BY ct.customerid, posteddate
				) AS cts
				INNER JOIN LND_TBOS.TollPlus_TP_CustTxns AS bb ON bb.custtxnid = cts.beginningcusttxnid
				INNER JOIN LND_TBOS.TollPlus_TP_CustTxns AS eb ON eb.custtxnid = cts.endingcusttxnid
		;
      	CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Loaded Stage.CustomerDailyBalanceWithActivity', 'I', -1, CAST(NULL as STRING));
		IF trace_flag = 1 THEN
			SELECT
					'EDW_TRIPS_STAGE.CustomerDailyBalanceWithActivity' AS src,
					CustomerDailyBalanceWithActivity.*
			FROM
				EDW_TRIPS_STAGE.CustomerDailyBalanceWithActivity
			ORDER BY customerid, balancestartdate
			LIMIT 100;
      	END IF;
      	-- Insert a new record into the stage balance history table with No Activity (This row reflects only the last CustTxnID before the BalanceStartDate)
		IF isfullload = 1 THEN
			CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.CustomerDailyBalanceWithNoActivity
			CLUSTER BY CustomerID
			AS
				SELECT
					coalesce(CAST( cts.customerid as INT64), -1) AS customerid,
					CAST(cts.balanceenddate as DATE) AS balancestartdate,
					coalesce(0, 0) AS tolltxncount,
					coalesce(CAST(0 as NUMERIC), CAST(0 as NUMERIC)) AS tollamount,
					coalesce(CAST(0 as NUMERIC), CAST(0 as NUMERIC)) AS creditamount,
					coalesce(CAST(0 as NUMERIC), CAST(0 as NUMERIC)) AS debitamount,
					coalesce(0, 0) AS credittxncount,
					coalesce(0, 0) AS debittxncount,
					coalesce(CAST( eb.currentbalance as NUMERIC), CAST(0 as NUMERIC)) AS beginningbalanceamount,
					coalesce(CAST(eb.currentbalance as NUMERIC), CAST(0 as NUMERIC)) AS endingbalanceamount,
					coalesce(CAST(eb.currentbalance as NUMERIC), CAST(0 as NUMERIC)) AS calcendingbalanceamount,
					coalesce(CAST(0 as NUMERIC), CAST(0 as NUMERIC)) AS balancediffamount,
					CAST(NULL as INT64) AS beginningcusttxnid,
					cts.lastcusttxnid AS endingcusttxnid,
					current_datetime() AS edw_updatedate
				FROM
					(
					SELECT
						ct.customerid,
						max(ct.posteddate) AS balanceenddate,
						max(ct.custtxnid) AS lastcusttxnid
						FROM
						EDW_TRIPS.Dim_Customer AS c
						INNER JOIN LND_TBOS.TollPlus_TP_CustTxns AS ct ON ct.customerid = c.customerid
						AND c.accountcategorydesc = 'TagStore'
						AND ct.lnd_updatetype <> 'D'
						WHERE ct.posteddate < balancestartdate
						AND ct.balancetype = 'TollBal'
						AND ct.apptxntypecode NOT LIKE '%FAIL%'
						AND NOT EXISTS (
						SELECT
							1
							FROM
							EDW_TRIPS_STAGE.CustomerDailyBalanceWithActivity AS aeb
							WHERE ct.customerid = aeb.customerid
						)
						GROUP BY ct.customerid
					) AS cts
					INNER JOIN LND_TBOS.TollPlus_TP_CustTxns AS eb ON eb.custtxnid = cts.lastcusttxnid
			;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Loaded Stage.CustomerDailyBalanceWithNoActivity - One time during Full Load', 'I', -1, CAST(NULL as STRING));
			IF trace_flag = 1 THEN
				SELECT
					'EDW_TRIPS_STAGE.CustomerDailyBalanceWithNoActivity' AS src,
					CustomerDailyBalanceWithNoActivity.*
					FROM
					EDW_TRIPS_STAGE.CustomerDailyBalanceWithNoActivity
					ORDER BY
						balancestartdate DESC,
						customerid
					LIMIT 100;
        	END IF;
				
				/*
					SELECT COUNT(*) FROM Stage.CustomerDailyBalanceWithNoActivity WHERE EndingBalanceAmount = 0 -- 1268156 rows out of 3676233 row(s) -- SELECT 1268156/3676233. = 34.5%
					SELECT COUNT(*) FROM Stage.CustomerDailyBalanceWithNoActivity WHERE EndingBalanceAmount < 0 -- 484690 rows out of 3676233 row(s) -- SELECT 484690/3676233. = 13%
					SELECT TOP 10 * FROM Stage.CustomerDailyBalanceWithNoActivity WHERE EndingBalanceAmount = 0 -- CustomerID IN (2010747882, 2010619379)CustomerID IN (2010747882, 2010619379)
					SELECT TOP 10 * FROM Stage.CustomerDailyBalanceWithNoActivity WHERE EndingBalanceAmount < 0 -- CustomerID IN (2010747882, 2010619379)CustomerID IN (2010747882, 2010619379)
				*/
		ELSE
			
			CREATE OR REPLACE  TABLE EDW_TRIPS_STAGE.CustomerDailyBalanceOpenEnded
			CLUSTER BY CustomerID
			AS
				SELECT
					f.customerid,
					f.balancestartdate,
					f.tolltxncount,
					f.tollamount,
					f.creditamount,
					f.debitamount,
					f.credittxncount,
					f.debittxncount,
					f.beginningbalanceamount,
					f.endingbalanceamount,
					f.calcendingbalanceamount,
					f.balancediffamount,
					f.beginningcusttxnid,
					f.endingcusttxnid,
					current_datetime() AS edw_updatedate
				FROM
					EDW_TRIPS.Fact_CustomerDailyBalance AS f
				WHERE f.balanceenddate = DATE '9999-12-31'
				AND EXISTS (
					SELECT
						1
					FROM
						EDW_TRIPS_STAGE.CustomerDailyBalanceWithActivity AS bwa
					WHERE f.customerid = bwa.customerid
				) AND balancestartdate is not null
			;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Loaded Stage.CustomerDailyBalanceOpenEnded - Daily during Incremental Load', 'I', -1, CAST(NULL as STRING));
			END IF;

			IF trace_flag = 1 THEN
				SELECT
					'EDW_TRIPS_STAGE.CustomerDailyBalanceOpenEnded' AS src,
					CustomerDailyBalanceOpenEnded.*
					FROM
					EDW_TRIPS_STAGE.CustomerDailyBalanceOpenEnded
				ORDER BY
					customerid,
					balancestartdate
					LIMIT 100
				;
        END IF;

		--:: Load dbo.Fact_CustomerDailyBalance_NEW
		SET sql="""CREATE OR REPLACE TABLE
					EDW_TRIPS.Fact_CustomerDailyBalance_NEW """||createtablewith||""" AS
				   WITH
					cte_new AS (
					SELECT
						s.customerid,
						s.balancestartdate,
						s.tolltxncount,
						s.tollamount,
						s.creditamount,
						s.debitamount,
						s.credittxncount,
						s.debittxncount,
						s.beginningbalanceamount,
						s.endingbalanceamount,
						s.calcendingbalanceamount,
						s.balancediffamount,
						s.beginningcusttxnid,
						s.endingcusttxnid,
						s.edw_updatedate,
						ROW_NUMBER() OVER (PARTITION BY s.customerid, s.balancestartdate ORDER BY s.edw_updatedate DESC) AS rn
					FROM (
						SELECT
							*
						FROM
							EDW_TRIPS_STAGE.CustomerDailyBalanceWithActivity
						UNION DISTINCT
						SELECT
							*
						FROM (
							SELECT
								*
							FROM
								EDW_TRIPS_STAGE.CustomerDailyBalanceWithNoActivity
							WHERE
								"""||isfullload||"""=1
							UNION ALL
							SELECT
								*
							FROM
								EDW_TRIPS_STAGE.CustomerDailyBalanceOpenEnded
							WHERE
								"""||isfullload||"""!=1) ) AS s )
					SELECT
						cte_new.customerid,
						cte_new.balancestartdate,
						LEAD(DATE_SUB(cte_new.balancestartdate, INTERVAL 1 DAY), 1, '9999-12-31') OVER (PARTITION BY cte_new.customerid ORDER BY cte_new.balancestartdate) AS balanceenddate,
						cte_new.tolltxncount,
						cte_new.tollamount,
						cte_new.creditamount,
						cte_new.debitamount,
						cte_new.credittxncount,
						cte_new.debittxncount,
						cte_new.beginningbalanceamount,
						cte_new.endingbalanceamount,
						cte_new.calcendingbalanceamount,
						cte_new.balancediffamount,
						cte_new.beginningcusttxnid,
						cte_new.endingcusttxnid,
						cte_new.edw_updatedate
					FROM
						cte_new
					WHERE
						cte_new.rn = 1""";
		EXECUTE IMMEDIATE sql;
		SET log_message = 'Loaded EDW_TRIPS.Fact_CustomerDailyBalance';
		CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, substr(CAST(-1 as STRING), 1, 2147483647));

		IF trace_flag = 1 THEN
			SELECT
				'EDW_TRIPS.Fact_CustomerDailyBalance_NEW' AS src,
				*
				FROM
				EDW_TRIPS.Fact_CustomerDailyBalance_NEW
			ORDER BY
				customerid,
				balancestartdate
			LIMIT 100
			;
		END IF;

		
		--:: Full Load
		IF isfullload = 1 THEN
			-- Table swap!
			--CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Fact_CustomerDailyBalance_NEW', 'EDW_TRIPS.Fact_CustomerDailyBalance');
			--1003 person added  code
			CREATE OR REPLACE  TABLE  EDW_TRIPS.Fact_CustomerDailyBalance PARTITION BY DATE_TRUNC(balancestartdate, MONTH) OPTIONS ( require_partition_filter = False) as (select * from EDW_TRIPS.Fact_CustomerDailyBalance_New where balancestartdate is not null );
			SET log_message = 'Completed Full Load';
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));
		ELSE
			-- IF trace_flag = 1 THEN
			-- 	SELECT 'Calling: Utility.ManagePartitions_Date'
			-- END IF;
			--CALL EDW_TRIPS_SUPPORT.ManagePartitions_Date('EDW_TRIPS.Fact_CustomerDailyBalance', 'Month');
			
			--:: Delete old rows from the main table
			DELETE FROM EDW_TRIPS.Fact_CustomerDailyBalance WHERE EXISTS (
			SELECT
				customerid
				FROM
				EDW_TRIPS.Fact_CustomerDailyBalance_New
				WHERE Fact_CustomerDailyBalance_New.customerid = fact_customerdailybalance.customerid
				AND Fact_CustomerDailyBalance_New.balancestartdate = fact_customerdailybalance.balancestartdate
				AND  balancestartdate is not null
			) AND  balancestartdate is not null ;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Delete old rows from the main table dbo.Fact_CustomerDailyBalanceWithActivity', 'I', -1, CAST(NULL as STRING));
				
			--:: Add new rows from _NEW table which has new and modified rows
			INSERT INTO EDW_TRIPS.Fact_CustomerDailyBalance (customerid, balancestartdate, balanceenddate, tolltxncount, tollamount, creditamount, debitamount, credittxncount, debittxncount, beginningbalanceamount, endingbalanceamount, calcendingbalanceamount, balancediffamount, beginningcusttxnid, endingcusttxnid, edw_updatedate)
			SELECT
				Fact_CustomerDailyBalance_NEW.customerid,
				Fact_CustomerDailyBalance_NEW.balancestartdate,
				Fact_CustomerDailyBalance_NEW.balanceenddate,
				Fact_CustomerDailyBalance_NEW.tolltxncount,
				Fact_CustomerDailyBalance_NEW.tollamount,
				Fact_CustomerDailyBalance_NEW.creditamount,
				Fact_CustomerDailyBalance_NEW.debitamount,
				Fact_CustomerDailyBalance_NEW.credittxncount,
				Fact_CustomerDailyBalance_NEW.debittxncount,
				Fact_CustomerDailyBalance_NEW.beginningbalanceamount,
				Fact_CustomerDailyBalance_NEW.endingbalanceamount,
				Fact_CustomerDailyBalance_NEW.calcendingbalanceamount,
				Fact_CustomerDailyBalance_NEW.balancediffamount,
				Fact_CustomerDailyBalance_NEW.beginningcusttxnid,
				Fact_CustomerDailyBalance_NEW.endingcusttxnid,
				Fact_CustomerDailyBalance_NEW.edw_updatedate
				FROM
				EDW_TRIPS.Fact_CustomerDailyBalance_NEW
				WHERE  balancestartdate is not null
			;
			-- Log
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Inserted new rows from _NEW table which has new and modified rows into the main table dbo.Fact_CustomerDailyBalanceWithActivity', 'I', -1, CAST(NULL as STRING));
			SET log_message = 'Completed Incremental Daily Load';
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', CAST(NULL as INT64), CAST(NULL as STRING));	
		END IF;
		IF trace_flag = 1 THEN
			SELECT
				'EDW_TRIPS.Fact_CustomerDailyBalance' AS src,
				*
				FROM
				EDW_TRIPS.Fact_CustomerDailyBalance
				ORDER BY
					customerid DESC,
					balancestartdate
				LIMIT 1000
			;
		END IF;
		IF trace_flag = 1 THEN
			SELECT
				'EDW_TRIPS_SUPPORT.ProcessLog' AS src,
				*
				FROM
				EDW_TRIPS_SUPPORT.Processlog
				WHERE Processlog.logsource = 'EDW_TRIPS.Fact_CustomerDailyBalance_Load'
				AND Processlog.logdate >= log_start_date
			ORDER BY
				logdate DESC
			LIMIT 100
			;
		END IF;

		
		EXCEPTION WHEN ERROR THEN
		BEGIN
			DECLARE error_message STRING DEFAULT @@error.message;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
			SELECT @@error.message;
			RAISE USING MESSAGE = error_message; -- Rethrow the error!

		END;
	END;
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
  END;