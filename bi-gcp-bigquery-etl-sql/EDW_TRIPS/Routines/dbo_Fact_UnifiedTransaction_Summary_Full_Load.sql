CREATE OR REPLACE PROCEDURE EDW_TRIPS.Fact_UnifiedTransaction_Summary_Full_Load()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_UnifiedTransaction_Summary table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040134	Shankar		2021-12-10	New!
CHG0040343	Shankar		2022-01-31	1. Get OOSPlateFlag for all transaction types, not just video.
									2. Add the First Payment Date and Last Payment Date columns. 
									3. Get Paid Amount for prepaid trips from TP_CustomerTrips along with Adj.
CHG0040744	Shankar		2022-04-13	Added AdjustedExpectedAmount and few new columns from dbo.Fact_UnifiedTransaction
CHG0041141	Shankar		2022-06-17	Added LaneTripIdentMethodID, RecordTypeID, Rpt_PaidvsAEA from dbo.Fact_UnifiedTransaction
CHG0041406  Shekhar		2022-08-23  Added the following two columns 
									1. VTollFlag - A flag to identify if a transaction is VTolled or not
									2. ClassAdjustmentFlag - A flag to identify if a transaction has any class adjustment
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_UnifiedTransaction_Summary_Full_Load
 
SELECT * FROM Utility.ProcessLog Where LogSource = 'dbo.Fact_UnifiedTransaction_Summary_Full_Load' ORDER BY 1 DESC
SELECT TOP 1000 'Stage.UnifiedTransaction' TableName, * FROM Stage.UnifiedTransaction ORDER BY TripDate DESC,TPTripID
SELECT TOP 1000 'dbo.Fact_UnifiedTransaction' TableName, * FROM dbo.Fact_UnifiedTransaction ORDER BY TripDate DESC,TPTripID
SELECT TOP 1000 'dbo.Fact_UnifiedTransaction_Summary' TableName, * FROM dbo.Fact_UnifiedTransaction_Summary ORDER BY 2 DESC,3,4
###################################################################################################################
*/

    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_UnifiedTransaction_Summary_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
	DECLARE trace_flag INT64 DEFAULT 0;--Testing
    BEGIN
      	DECLARE row_count INT64;
      	SET log_start_date = current_datetime('America/Chicago');
      	CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
	  
		--=============================================================================================================
		-- dbo.Fact_UnifiedTransaction_Summary 
		--=============================================================================================================
     
	  	--DROP TABLE IF EXISTS EDW_TRIPS.Fact_UnifiedTransaction_Summary_NEW;
      	CREATE OR REPLACE TABLE EDW_TRIPS.Fact_UnifiedTransaction_Summary 
        AS
          SELECT
              Fact_UnifiedTransaction.tripdayid,
              Fact_UnifiedTransaction.laneid,
              Fact_UnifiedTransaction.operationsmappingid,
              Fact_UnifiedTransaction.tripwith,
              Fact_UnifiedTransaction.sourceofentry,
              Fact_UnifiedTransaction.tripidentmethodid,
              Fact_UnifiedTransaction.lanetripidentmethodid,
              Fact_UnifiedTransaction.recordtypeid,
              Fact_UnifiedTransaction.transactionpostingtypeid,
              Fact_UnifiedTransaction.tripstageid,
              Fact_UnifiedTransaction.tripstatusid,
              Fact_UnifiedTransaction.reasoncodeid,
              Fact_UnifiedTransaction.citationstageid,
              Fact_UnifiedTransaction.trippaymentstatusid,
              Fact_UnifiedTransaction.vehicleclassid,
              Fact_UnifiedTransaction.badaddressflag,
              Fact_UnifiedTransaction.nonrevenueflag,
              Fact_UnifiedTransaction.businessrulematchedflag,
              Fact_UnifiedTransaction.manuallyreviewedflag,
              Fact_UnifiedTransaction.oosplateflag,
              Fact_UnifiedTransaction.vtollflag,
              Fact_UnifiedTransaction.classadjustmentflag,
              Fact_UnifiedTransaction.rpt_paidvsaea,
              CAST( Fact_UnifiedTransaction.firstpaiddate as DATE) AS firstpaiddate,
              CAST( Fact_UnifiedTransaction.lastpaiddate as DATE) AS lastpaiddate,
              count(1) AS txncount,
              CAST(sum(Fact_UnifiedTransaction.expectedamount) as NUMERIC) AS expectedamount,
              CAST(sum(Fact_UnifiedTransaction.adjustedexpectedamount) as NUMERIC) AS adjustedexpectedamount,
              CAST(sum(Fact_UnifiedTransaction.calcadjustedamount) as NUMERIC) AS calcadjustedamount,
              CAST(sum(Fact_UnifiedTransaction.tripwithadjustedamount) as NUMERIC) AS tripwithadjustedamount,
              CAST(sum(Fact_UnifiedTransaction.tollamount) as NUMERIC) AS tollamount,
              CAST(sum(Fact_UnifiedTransaction.actualpaidamount) as NUMERIC) AS actualpaidamount,
              CAST(sum(Fact_UnifiedTransaction.outstandingamount) as NUMERIC) AS outstandingamount,
              max(Fact_UnifiedTransaction.lnd_updatedate) AS lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS.Fact_UnifiedTransaction
            GROUP BY tripdayid
					, laneid
					, operationsmappingid
					, tripwith
					, sourceofentry
					, tripidentmethodid
					, lanetripidentmethodid
					, recordtypeid
					, transactionpostingtypeid
					, tripstageid
					, tripstatusid
					, reasoncodeid
					, citationstageid
					, trippaymentstatusid
					, vehicleclassid
					, badaddressflag
					, nonrevenueflag
					, businessrulematchedflag
					, manuallyreviewedflag
					, oosplateflag
					, vtollflag
					, classadjustmentflag
					, rpt_paidvsaea
					, cast(firstpaiddate as date)  
					, cast(lastpaiddate as date)
				 ;
		SET log_message = 'Loaded EDW_TRIPS.Fact_UnifiedTransaction_Summary';
		CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));

		-- Table Swap Not Required as we are using Create or Replace in BQ 
		-- Table swap!
		--CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Fact_UnifiedTransaction_Summary_NEW', 'EDW_TRIPS.Fact_UnifiedTransaction_Summary'); 
		CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
		
		IF trace_flag = 1 THEN
			SELECT
				'EDW_TRIPS.Fact_UnifiedTransaction_Summary' AS tablename,
				*
				FROM
				EDW_TRIPS.Fact_UnifiedTransaction_Summary
			ORDER BY
				2 DESC
			LIMIT 1000
			;
		END IF;

	  
		EXCEPTION WHEN ERROR THEN
		BEGIN
			DECLARE error_message STRING DEFAULT @@error.message;
			CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
			-- CALL EDW_TRIPS_SUPPORT.FromLog(log_source, log_start_date);
			select log_source, log_start_date;
			RAISE USING MESSAGE = error_message; -- Rethrow the error!
		END;
	END;
    
/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Fact_UnifiedTransaction_Summary_Full_Load
SELECT * FROM Utility.ProcessLog Where LogSource = 'dbo.Fact_UnifiedTransaction_Summary_Full_Load' ORDER BY 1 DESC
SELECT TOP 100 'dbo.Fact_UnifiedTransaction' Table_Name, * FROM dbo.Fact_UnifiedTransaction ORDER BY 2
SELECT TOP 100 'dbo.Fact_UnifiedTransaction_Summary' Table_Name, * FROM dbo.Fact_UnifiedTransaction_Summary ORDER BY 2

*/
  END;