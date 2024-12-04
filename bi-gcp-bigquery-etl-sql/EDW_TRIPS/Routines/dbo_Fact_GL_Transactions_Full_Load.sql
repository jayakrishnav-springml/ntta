CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_GL_Transactions_Full_Load`()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_GL_Transactions table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838 	Arun		2020-11-01	New!
CHG0038040  Arun Krishna 2021-01-27 -- Added Delete Flag 


===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_GL_Transactions_Full_Load

EXEC Utility.FromLog 'dbo.Fact_GL_Transactions', 1
SELECT TOP 100 'dbo.Fact_GL_Transactions' Table_Name, * FROM dbo.Fact_GL_Transactions ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_GL_Transactions_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);
      --=============================================================================================================
      -- Load dbo.Fact_GL_Transactions
      --=============================================================================================================
	    
      CREATE OR REPLACE  TABLE EDW_TRIPS.Fact_GL_Transactions
      cluster by GL_TxnID
        AS
          SELECT
              Finance_GL_Transactions.gl_txnid,
              Finance_GL_Transactions.postingdate,
              Finance_GL_Transactions.postingdate_yyyymm,
              Finance_GL_Transactions.customerid,
              Finance_GL_Transactions.txntypeid,
              Finance_GL_Transactions.businessprocessid,
              Finance_GL_Transactions.linkid,
              Finance_GL_Transactions.linksourcename,
              Finance_GL_Transactions.txndate,
              Finance_GL_Transactions.txnamount,
              Finance_GL_Transactions.iscontra,
              Finance_GL_Transactions.description AS description,
              NULL AS requestid,
              Finance_GL_Transactions.businessunitid,
              Finance_GL_Transactions.createddate,
              Finance_GL_Transactions.createduser,
              Finance_GL_Transactions.updateddate,
              Finance_GL_Transactions.updateduser,
              CASE
                WHEN Finance_GL_Transactions.lnd_updatetype = 'D' THEN 1
                ELSE 0
              END AS deleteflag,
              Finance_GL_Transactions.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.Finance_GL_Transactions
            WHERE Finance_GL_Transactions.lnd_updatetype <> 'D'
      ;
      SET log_message = 'Loaded EDW_TRIPS.Fact_GL_Transactions';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
      --Table swap!
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Fact_GL_Transactions_NEW', 'EDW_TRIPS.Fact_GL_Transactions');
      --TableSwap is Not Required, using  Create or Replace Table
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_GL_Transactions' AS tablename,
            *
          FROM
            EDW_TRIPS.Fact_GL_Transactions
        ORDER BY
          2 DESC
        LIMIT 1000
        ;
      END IF;

    END;
    EXCEPTION WHEN ERROR THEN
       BEGIN
          DECLARE error_message STRING DEFAULT @@error.message;
          CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
          RAISE USING MESSAGE = error_message;  -- Rethrow the error!
       END;
/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
EXEC dbo.Fact_GL_Transactions_Full_Load

EXEC Utility.FromLog 'dbo.Fact_GL_Transactions', 1
SELECT TOP 100 'dbo.Fact_GL_Transactions' Table_Name, * FROM dbo.Fact_GL_Transactions ORDER BY 2

--===============================================================================================================
-- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
--===============================================================================================================


*/
    END;