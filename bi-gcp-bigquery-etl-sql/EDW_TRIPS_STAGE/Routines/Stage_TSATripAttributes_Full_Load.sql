CREATE OR REPLACE PROCEDURE EDW_TRIPS_STAGE.TSATripAttributes_Full_Load()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load Stage.TSATripAttributes table to optmize dbo.Fact_UnifiedTransaction load as part of Bubble ETL Process 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0040744	Shankar		2022-03-22	New!
CHG0040994	Shankar		2022-05-26	Added Discount related TSA columns
CHG0041141	Shankar		2022-06-30	In case of multiple submissions of a Txn, take the first one for Expected Amount
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Stage.TSATripAttributes_Full_Load
SELECT * FROM Utility.ProcessLog WHERE LogSource = 'Stage.TSATripAttributes_Full_Load' ORDER BY 1 DESC
SELECT TOP 100 'Stage.TSATripAttributes' Table_Name, * FROM  Stage.TSATripAttributes ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS_STAGE.TSATripAttributes_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;-- Testing
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime();
      CALL  EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      
		--=============================================================================================================
		-- Load Stage.TSATripAttributes
		--=============================================================================================================
      CREATE OR REPLACE TABLE EDW_TRIPS_STAGE.TSATripAttributes CLUSTER BY tptripid
        AS(
          --EXPLAIN
          SELECT
              ea.tptripid,
              ea.sourcetripid,
              ea.tripdate, 
              ea.recordtype,
              ea.vehiclespeed,
              ea.vehicleclassification,
              ea.transactiontype,
              ea.transpondertollamount,
              ea.videotollamountwithvideotollpremium,
              ea.videotollamountwithoutvideotollpremium,
              ea.tsa_receivedtollamount,
              ea.tsa_base,
              ea.tsa_premium,
              ea.transponderdiscounttype,
              ea.discountedtranspondertollamount,
              ea.videodiscounttype,
              ea.discountedvideotollamountwithoutvideotollpremium,
              ea.discountedvideotollamountwithvideotollpremium,
              ea.lnd_updatedate,
              ea.edw_updatedate
            FROM
              (
                SELECT
                    tt.tptripid,
                    tt.sourcetripid,
                    tt.exittripdatetime AS tripdate,-- RT.Timestamp is TripDateUTC
                    traw.recordtype,
                    traw.speed AS vehiclespeed,
                    traw.vehicleclassification,
                    ta.transactiontype,
                    ta.transpondertollamount,
                    ta.videotollamountwithvideotollpremium,
                    ta.videotollamountwithoutvideotollpremium,
                    CASE
                       ta.transactiontype
                      WHEN 'T' THEN ta.transpondertollamount
                      WHEN 'V' THEN ta.videotollamountwithvideotollpremium
                    END AS tsa_receivedtollamount,
                    CASE
                       ta.transactiontype
                      WHEN 'T' THEN ta.transpondertollamount
                      WHEN 'V' THEN ta.videotollamountwithoutvideotollpremium
                    END AS tsa_base,
                    CASE
                       ta.transactiontype
                      WHEN 'T' THEN 0
                      WHEN 'V' THEN ta.videotollamountwithvideotollpremium - ta.transpondertollamount
                    END AS tsa_premium,
                    ta.transponderdiscounttype,
                    ta.discountedtranspondertollamount,
                    ta.videodiscounttype,
                    ta.discountedvideotollamountwithoutvideotollpremium,
                    ta.discountedvideotollamountwithvideotollpremium,
                    coalesce(ta.lnd_updatedate, traw.lnd_updatedate) AS lnd_updatedate,
                    current_datetime() AS edw_updatedate,
                    row_number() OVER (PARTITION BY tt.tptripid ORDER BY ta.updateddate) AS rn
                  FROM
                    LND_TBOS.TollPlus_TP_Trips AS tt
                    LEFT OUTER JOIN LND_TBOS.TSA_TSATripAttributes AS ta  -- main table
                      ON ta.tptripid = tt.tptripid AND ta.lnd_updatetype <> 'D' -- optional table
                    LEFT OUTER JOIN LND_TBOS.TranProcessing_TSARawTransactions AS traw 
                    ON traw.txnid = tt.sourcetripid
                     AND traw.lnd_updatetype <> 'D'
                  WHERE tt.exit_tolltxnid >= 0
                   AND tt.tptripid > 0
                   AND tt.sourceofentry = 3  -- TSA
                   AND tt.exittripdatetime >= CAST('2019-01-01' AS DATETIME)-- @FirstDateToLoad
                   AND tt.exittripdatetime < current_datetime()
                   AND tt.lnd_updatetype <> 'D'
              ) AS ea
            WHERE ea.rn = 1)
      
      ;
      SET log_message = 'Loaded   EDW_TRIPS_STAGE.TSATripAttributes';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING)); 
      --using craete and replace
      -- Table swap!
      --CALL EDW_TRIPS_SUPPORT.tableswap('EDW_TRIPS_STAGE.TSATripAttributes_NEW', 'EDW_TRIPS_STAGE.TSATripAttributes');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      IF trace_flag = 1 THEN
        SELECT  'EDW_TRIPS_STAGE.TSATripAttributes' AS tablename, *
          FROM EDW_TRIPS_STAGE.TSATripAttributes
          ORDER BY 2 DESC
          LIMIT 1000 ;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        RAISE USING MESSAGE = error_message;-- Rethrow the error!
      END;
    END;
    
  /*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC Stage.TSATripAttributes_FullLoad
SELECT * FROM Utility.ProcessLog WHERE LogSource = 'Stage.TSATripAttributes_Full_Load' ORDER BY 1 DESC
SELECT TOP 100 'Stage.TSATripAttributes' Table_Name, * FROM Stage.TSATripAttributes WHERE TPTripID = 2017948180 ORDER BY 2

--===============================================================================================================
-- USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel
--===============================================================================================================

SELECT COUNT(*) FROM LND_TBOS.TSA.TSATripAttributes WHERE TransponderDiscountType IS NOT NULL
SELECT TOP 10 * FROM LND_TBOS.TSA.TSATripAttributes WHERE TransponderDiscountType IS NOT NULL AND TransactionDate > 20210106
SELECT TOP 10 * FROM LND_TBOS.TSA.TSATripAttributes WHERE VideoDiscountType IS NOT NULL AND TransactionDate > 20210106
SELECT YEAR(TransactionDate) TripYear, COUNT(1) RC FROM LND_TBOS.TSA.TSATripAttributes WHERE TransponderDiscountType IS NOT NULL GROUP BY YEAR(TransactionDate) ORDER BY 1
 
SELECT COUNT(*) FROM LND_TBOS.TSA.TSATripAttributes WHERE VideoDiscountType IS NOT NULL
SELECT TOP 10 * FROM LND_TBOS.TSA.TSATripAttributes WHERE VideoDiscountType IS NOT NULL AND TransactionDate > 20210106
SELECT TOP 10 * FROM LND_TBOS.TSA.TSATripAttributes WHERE VideoDiscountType IS NOT NULL AND TransactionDate > 20210106
SELECT YEAR(TransactionDate) TripYear, COUNT(1) RC FROM LND_TBOS.TSA.TSATripAttributes WHERE VideoDiscountType IS NOT NULL GROUP BY YEAR(TransactionDate) ORDER BY 1 -- only migrated data has this scenario.

*/
    END;
