CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Dim_AppTxnType_Full_Load`()
BEGIN
/*
IF OBJECT_ID ('dbo.Dim_AppTxnType_Full_Load', 'P') IS NOT NULL DROP PROCEDURE dbo.Dim_AppTxnType_Full_Load
####################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_AppTxnType table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Gouthami		2020-10-13	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_AppTxnType_Full_Load 

EXEC Utility.FromLog 'dbo.Dim_AppTxnType', 1
SELECT 'LND_TBOS.MIR.ReasonCodes' Table_name,* FROM LND_TBOS.MIR.ReasonCodes ORDER BY 2
SELECT TOP 100 'dbo.Dim_AppTxnType' Table_Name, * FROM dbo.Dim_AppTxnType ORDER BY 2
####################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_AppTxnType_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;-- Testing
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      
      --=============================================================================================================
      -- Load dbo.Dim_AppTxnType
      --=============================================================================================================
      
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_AppTxnType CLUSTER BY AppTxnTypeID
        AS
          SELECT
              tt.apptxntypeid,
              tt.apptxntypecode,
              tt.apptxntypedesc,
              substr(CAST(replace(replace(replace(replace(replace(replace(replace(nullif(effected_balancetype_positive, ''), 'AdmHeriFee', 'AdmHeriFee'), 'AdvancePayment', 'AdvancePayment'), 'ZipCash', 'ZipCash'), 'EMIBal', 'EMIBal'), 'VioBal', 'VioBal'), 'CollBal', 'CollBal'), 'TollBal', 'TollBal') AS STRING),1,20) AS effected_balancetype_positive,
              substr(CAST(replace(replace(replace(replace(replace(replace(replace(nullif(effected_balancetype_negative, ''), 'AdmHeriFee', 'AdmHeriFee'), 'AdvancePayment', 'AdvancePayment'), 'ZipCash', 'ZipCash'), 'EMIBal', 'EMIBal'), 'VioBal', 'VioBal'), 'CollBal', 'CollBal'), 'TollBal', 'TollBal') AS STRING ),1,20) AS effected_balancetype_negative,
              substr(CAST(replace(replace(replace(replace(replace(replace(replace(nullif(main_balance_type, ''), 'AdmHeriFee', 'AdmHeriFee'), 'AdvancePayment', 'AdvancePayment'), 'ZipCash', 'ZipCash'), 'EMIBal', 'EMIBal'), 'VioBal', 'VioBal'), 'CollBal', 'CollBal'), 'TollBal', 'TollBal') AS STRING),1,20) AS main_balance_type,
              tc1.categoryid AS txntypecategoryid,
              concat(left(tc1.categoryname, 1), lower(substr(tc1.categoryname, 2, 50))) AS txntypecategory,
              coalesce(tc2.categoryid, tc1.categoryid) AS txntypeparentcategoryid,
              coalesce(concat(left(tc2.categoryname, 1), lower(substr(tc2.categoryname, 2, 50))), concat(left(tc1.categoryname, 1), lower(substr(tc1.categoryname, 2, 50)))) AS txntypeparentcategory,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.TollPlus_AppTxnTypes AS tt
              INNER JOIN LND_TBOS.TollPlus_TxnType_Categories AS tc1 ON tt.txntype_categoryid = tc1.categoryid
              LEFT OUTER JOIN LND_TBOS.TollPlus_TxnType_Categories AS tc2 ON tc1.parent_categoryid = tc2.categoryid
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              'Unknown',
              'Unknown',
              'Unknown',
              -1,
              'Unknown',
              -1,
              'Unknown',
              current_datetime() AS edw_updatedate
      ;
      SET log_message = 'Loaded dbo.Dim_AppTxnType';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
      
      -- Table swap!
      --using create and replace in bigquery
      --CALL EDW_TRIPS_utility.TableSwap('EDW_TRIPS.Dim_AppTxnType_NEW', 'EDW_TRIPS.Dim_AppTxnType');
      
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      -- Show results
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_AppTxnType' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_AppTxnType
        ORDER BY 2 DESC 
        LIMIT 1000;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
        --CALL utility.fromlog(log_source, log_start_date);
        SELECT log_source,log_start_date;
        RAISE USING MESSAGE = error_message;
        -- Rethrow the error!
      END;
    /*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_AppTxnType_Full_Load

EXEC Utility.FromLog 'dbo.Dim_AppTxnType', 1
SELECT 'LND_TBOS.MIR.ReasonCodes' Table_name,* FROM LND_TBOS.MIR.ReasonCodes ORDER BY 2
SELECT TOP 100 'dbo.Dim_AppTxnType' Table_Name, * FROM dbo.Dim_AppTxnType ORDER BY 2

*/
    END;
  END;