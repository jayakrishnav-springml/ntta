CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Dim_ChartOfAccounts_Full_Load`()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_ChartOfAccounts table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	ARUN		2020-11-09	Created

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_ChartOfAccounts_Full_Load

EXEC Utility.FromLog 'dbo.Dim_ChartOfAccounts', 1
SELECT TOP 100 'dbo.Dim_ChartOfAccounts' Table_Name, * FROM dbo.Dim_ChartOfAccounts ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_ChartOfAccounts_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);

      --=============================================================================================================
      -- Load dbo.Dim_ChartOfAccounts
      --=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_ChartOfAccounts;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_ChartOfAccounts CLUSTER BY ChartOfAccountID 
        AS
          SELECT
              Finance_ChartOfAccounts.surrogate_coaid,
              Finance_ChartOfAccounts.chartofaccountid,
              Finance_ChartOfAccounts.accountname,
              Finance_ChartOfAccounts.parentchartofaccountid,
              Finance_ChartOfAccounts.agcode,
              Finance_ChartOfAccounts.asgcode,
              Finance_ChartOfAccounts.lowerbound,
              Finance_ChartOfAccounts.upperbound,
              Finance_ChartOfAccounts.status,
              Finance_ChartOfAccounts.iscontrolaccount,
              Finance_ChartOfAccounts.normalbalancetype,
              Finance_ChartOfAccounts.legalaccountid,
              Finance_ChartOfAccounts.agencycode,
              Finance_ChartOfAccounts.starteffectivedate,
              Finance_ChartOfAccounts.endeffectivedate,
              Finance_ChartOfAccounts.comments,
              Finance_ChartOfAccounts.isdeleted,
              Finance_ChartOfAccounts.createddate,
              Finance_ChartOfAccounts.createduser,
              Finance_ChartOfAccounts.updateddate,
              Finance_ChartOfAccounts.updateduser,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.Finance_ChartOfAccounts
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_ChartOfAccounts';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_ChartOfAccounts_NEW', 'EDW_TRIPS.Dim_ChartOfAccounts');

      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_ChartOfAccounts' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_ChartOfAccounts
            ORDER BY 2 DESC LIMIT 1000;
      END IF;

    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
      END;
    END;
    /*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_ChartOfAccounts_Load

EXEC Utility.FromLog 'dbo.Dim_ChartOfAccounts', 1
SELECT TOP 100 'dbo.Dim_ChartOfAccounts' Table_Name, * FROM dbo.Dim_ChartOfAccounts ORDER BY 2


*/
  END;