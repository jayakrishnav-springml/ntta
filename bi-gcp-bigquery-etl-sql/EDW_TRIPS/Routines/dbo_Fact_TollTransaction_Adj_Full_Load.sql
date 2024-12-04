CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_TollTransaction_Adj_Full_Load`()
BEGIN

/*
###################################################################################################################
Proc Description: 
##################################################################################################################-
Load dbo.Fact_TollTransaction_Adj table. 
This Proc accommodate different adjustment dates for the same customer
===================================================================================================================
Change Log:
##################################################################################################################-
CHG0039407	Sagarika		2020-10-01	New!

===================================================================================================================
Example:
##################################################################################################################-
EXEC dbo.Fact_TollTransaction_Adj_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Fact_TollTransaction_Adj_Full_Load%' ORDER BY 1 DESC 
SELECT TOP 100 'dbo.Fact_TollTransaction_Adj' Table_Name, * FROM  dbo.Fact_TollTransaction_Adj ORDER BY 2
###################################################################################################################
*/


    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_TollTransaction_Adj_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      --=============================================================================================================
      -- Load dbo.Fact_TollTransaction_Adj
      --=============================================================================================================

      -- DROP TABLE IF EXISTS EDW_TRIPS.Fact_TollTransaction_Adj_NEW;
      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_TollTransaction_Adj
      CLUSTER by custtripid
        AS
          SELECT
              coalesce(CAST(tp.custtripid as INT64), -1) AS custtripid,
              coalesce(CAST(adjli.adjlineitemid as INT64), -1) AS adjlineitemid,
              coalesce(CAST(adj.adjustmentid as INT64), -1) AS adjustmentid,
              coalesce(tp.tptripid, -1) AS tptripid,
              coalesce(CAST(tp.customerid as INT64), -1) AS customerid,
              coalesce(CAST(tp.exitlaneid as INT64), -1) AS laneid,
              coalesce(CAST(ti.tripidentmethodid as INT64), -1) AS tripidentmethodid,
              coalesce(CAST(CAST(tp.exittripdatetime as STRING  FORMAT 'YYYYMMDD') as INT64), -1) AS tripdayid,
              coalesce(CAST(CAST(adj.approvedstatusdate as STRING  FORMAT 'YYYYMMDD') as INT64), -1) AS adjusteddayid,
              coalesce(CAST(tp.exittripdatetime as DATETIME), DATETIME '1900-01-01 00:00:00') AS tripdate,
              coalesce(CAST(tp.posteddate as DATETIME), DATETIME '1900-01-01 00:00:00') AS posteddate,
              coalesce(CAST(adj.approvedstatusdate as DATETIME), DATETIME '1900-01-01 00:00:00') AS adjusteddate,
              CAST(adj.drcrflag as STRING) AS drcrflag,
              coalesce(CASE
                WHEN tp.lnd_updatetype = 'D' THEN 1
                ELSE 0
              END, 0) AS deleteflag,
              coalesce(CAST(adj.amount * CASE
                WHEN adj.drcrflag = 'D' THEN -1
                ELSE 1
              END as NUMERIC), CAST(0 as NUMERIC)) AS adjustedtollamount,
              coalesce(CAST(tp.lnd_updatedate as DATETIME), DATETIME '1900-01-01 00:00:00') AS lnd_updatedate,
              coalesce(current_datetime(), DATETIME '1900-01-01 00:00:00') AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_TP_CustomerTrips AS tp
              INNER JOIN LND_TBOS.Finance_Adjustment_LineItems AS adjli ON tp.custtripid = adjli.linkid
               AND adjli.linksourcename = 'TOLLPLUS.TP_CUSTOMERTRIPS'
               AND adjli.lnd_updatetype <> 'D'
              INNER JOIN LND_TBOS.Finance_Adjustments AS adj ON adj.adjustmentid = adjli.adjustmentid
               AND adj.approvedstatusid = 466
               AND adj.lnd_updatetype <> 'D'
              LEFT OUTER JOIN EDW_TRIPS.Dim_TripIdentMethod AS ti ON ti.tripidentmethod = tp.tripidentmethod
      ;
      SET log_message = 'Loaded EDW_TRIPS.Fact_TollTransaction_Adj';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Fact_TollTransaction_Adj_NEW', 'EDW_TRIPS.Fact_TollTransaction_Adj');
      -- SET log_message = 'Completed EDW_TRIPS.Fact_TollTransaction_Adj table swap';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      -- Show results
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_TollTransaction_Adj' AS tablename,
            *
          FROM
            EDW_TRIPS.Fact_TollTransaction_Adj
        ORDER BY
          2 DESC
        LIMIT 1000
        ;
      END IF;

    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = ''; -- Rethrow the error!
      END;
    END;
       /*
##===============================================================================================================
## DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
##===============================================================================================================
EXEC dbo.Fact_TollTransaction_Adj_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource LIKE '%Fact_TollTransaction_Adj_Full_Load%' ORDER BY 1 DESC 
SELECT TOP 100 'dbo.Fact_TollTransaction_Adj' Table_Name, * FROM  dbo.Fact_TollTransaction_Adj ORDER BY 2

##===============================================================================================================
## USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
##===============================================================================================================


*/
  END;