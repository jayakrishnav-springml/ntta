CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Fact_GL_Txn_LineItems_Full_Load`()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Fact_GL_Txn_LineItems table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838 	Arun		2020-11-01	New!
CHG0038040  Arun Krishna 2021-01-27 -- Added Delete Flag 


===================================================================================================================
Example:
--------------------------------------------------------------------------------------------------------------
EXEC dbo.Fact_GL_Txn_LineItems_Full_Load
EXEC Utility.FromLog 'dbo.Fact_GL_Txn_LineItems', 1
SELECT TOP 100 'dbo.Fact_GL_Txn_LineItems' Table_Name, * FROM dbo.Fact_GL_Txn_LineItems ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Fact_GL_Txn_LineItems_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);
	  
      --=============================================================================================================
      -- Load dbo.Fact_GL_Txn_LineItems
      --=============================================================================================================
  
      --DROP TABLE IF EXISTS EDW_TRIPS.Fact_GL_Txn_LineItems;
      CREATE OR REPLACE TABLE EDW_TRIPS.Fact_GL_Txn_LineItems
      CLUSTER BY PK_ID
        AS
          SELECT
              Finance_GL_Txn_LineItems.pk_id,
              Finance_GL_Txn_LineItems.gl_txnid,
              Finance_GL_Txn_LineItems.description AS description,
              Finance_GL_Txn_LineItems.chartofaccountid,
              Finance_GL_Txn_LineItems.debitamount,
              Finance_GL_Txn_LineItems.creditamount,
              Finance_GL_Txn_LineItems.specialjournalid,
              Finance_GL_Txn_LineItems.drcr_flag,
              Finance_GL_Txn_LineItems.txntype_li_id,
              Finance_GL_Txn_LineItems.txntypeid,
              Finance_GL_Txn_LineItems.createddate,
              Finance_GL_Txn_LineItems.createduser,
              Finance_GL_Txn_LineItems.updateddate,
              Finance_GL_Txn_LineItems.updateduser,
              CASE
                WHEN Finance_GL_Txn_LineItems.lnd_updatetype = 'D' THEN 1
                ELSE 0
              END AS deleteflag,
              Finance_GL_Txn_LineItems.lnd_updatedate,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.Finance_GL_Txn_LineItems
            WHERE Finance_GL_Txn_LineItems.lnd_updatetype <> 'D'
      ;
      SET log_message = 'Loaded EDW_TRIPS.Fact_GL_Txn_LineItems';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
	    --Table swap!
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Fact_GL_Txn_LineItems_NEW', 'EDW_TRIPS.Fact_GL_Txn_LineItems');
      --TableSwap is Not Required, using  Create or Replace Table
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Fact_GL_Txn_LineItems' AS tablename,
            *
          FROM
            EDW_TRIPS.Fact_GL_Txn_LineItems
        ORDER BY
          2 DESC
        LIMIT 1000
        ;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        RAISE USING MESSAGE = ' '; -- Rethrow the error!
      END;
    END;
/*
--===============================================================================================================
-- !!! DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios !!!
--===============================================================================================================
EXEC dbo.Fact_GL_Txn_LineItems_Full_Load

EXEC Utility.FromLog 'dbo.Fact_GL_Txn_LineItems', 1
SELECT TOP 100 'dbo.Fact_GL_Txn_LineItems' Table_Name, * FROM dbo.Fact_GL_Txn_LineItems ORDER BY 2

--===============================================================================================================
-- !!! USEFUL DATA VALIDATION SCRIPTS for post prod move monitoring or for others to not reinvent the wheel !!! 
--===============================================================================================================


*/
  END;