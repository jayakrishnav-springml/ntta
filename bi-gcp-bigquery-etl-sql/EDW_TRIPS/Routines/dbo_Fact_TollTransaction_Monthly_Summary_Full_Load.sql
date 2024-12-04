CREATE OR REPLACE PROCEDURE EDW_TRIPS.Fact_TollTransaction_Monthly_Summary_Full_Load()
  BEGIN
  /*
  ############################################################################################################################################
  Proc Description: 
  --------------------------------------------------------------------------------------------------------------------------------------------
  Loads dbo.Fact_TollTransaction_Monthly_Summary. This table provides monthly summary of Customer Toll Txn data from Bubble fact table. 
  ============================================================================================================================================
  Change Log:
  --------------------------------------------------------------------------------------------------------------------------------------------
  CHG0044450	Sagarika 		2023-12-28  	New!
  ============================================================================================================================================
  Example:
  --------------------------------------------------------------------------------------------------------------------------------------------
  EXEC dbo.Fact_TollTransaction_Monthly_Summary_Full_Load
  SELECT * FROM Utility.ProcessLog Where LogSource = 'dbo.Fact_TollTransaction_MonthlySummary_Full_Load' ORDER BY 1 DESC
  SELECT TOP 1000 * FROM dbo.Fact_TollTransaction_Monthly_Summary ORDER BY CustomerID ASC, TripMonthID DESC, VehicleID, CustTagID
  ############################################################################################################################################
  */
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_TollTransaction_MonthlySummary_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE tablename STRING DEFAULT 'EDW_TRIPS.Fact_CustomerTagDetail';
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);
      
      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_TollTransaction_Monthly_Summary
        AS
          SELECT
              c.customerid,
              cast(div(tripdayid, 100) as INT64) AS tripmonthid,
              coalesce(CAST( v.vehicleid as INT64), -1) AS vehicleid,
              coalesce(CAST( fut.custtagid as INT64), -1) AS custtagid,
              fut.operationsmappingid,-- Gateway to dbo.Dim_OperationsMapping columns which include TripIdentMethodID, TransactionPostingTypeID and a bunch more! Very valuable Bubble column
              l.facilityid,
              count(1) AS txncount,
              coalesce(sum(fut.adjustedexpectedamount), CAST(0 as NUMERIC)) AS adjustedexpectedamount,
              coalesce(sum(fut.actualpaidamount), CAST(0 as NUMERIC)) AS actualpaidamount,
              current_datetime() AS edw_updatedate
            FROM
              EDW_TRIPS.Fact_UnifiedTransaction AS fut
              INNER JOIN EDW_TRIPS.Dim_Customer AS c ON c.customerid = fut.customerid
              INNER JOIN EDW_TRIPS.Dim_Lane AS l ON l.laneid = fut.laneid
              LEFT OUTER JOIN EDW_TRIPS.Dim_vehicle AS v ON fut.vehicleid = v.vehicleid -- This check can be taken away when dbo.Fact_UnifiedTransaction load handles it.
            WHERE accountcategorydesc = 'TagStore'
              AND fut.tripdayid >= 20210101
              AND fut.tripstatusid = 2-- Posted
            GROUP BY c.customerid, tripmonthid, vehicleid, custtagid, fut.operationsmappingid, l.facilityid
      ;
      SET log_message = 'Loaded EDW_TRIPS.Fact_TollTransaction_Monthly_Summary';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      --TABLE SWAP
      --CALL EDW_TRIPS_SUPPORT.tableswap('EDW_TRIPS.Fact_TollTransaction_Monthly_Summary', 'EDW_TRIPS.Fact_TollTransaction_Monthly_Summary');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
      -- Show results
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_TollTransaction_Monthly_Summary' AS tablename,
            *
          FROM
            EDW_TRIPS.Fact_TollTransaction_Monthly_Summary
          ORDER BY
            customerid,
            tripmonthid
          LIMIT 1000
        ;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        RAISE USING MESSAGE = ''; -- Rethrow the error!
      END;
    END;
  /*
  --===============================================================================================================
  -- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
  --===============================================================================================================

  SELECT * FROM dbo.Fact_TollTransaction_MonthlySummary WHERE	CustomerID = 6680625 ORDER BY CustomerID, TripMonthID
  SELECT * FROM dbo.Dim_Customer WHERE LastName ='TULSHIBAGWALE' and  CustomerID = 6680625 and  AccountCategoryDesc = 'TagStore'
  SELECT * FROM dbo.Dim_Vehicle WHERE CustomerID = 6680625
  SELECT * FROM dbo.Dim_CustomerTag WHERE CustomerID = 6680625

  */
  END;
