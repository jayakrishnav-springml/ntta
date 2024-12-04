CREATE OR REPLACE PROCEDURE `EDW_TRIPS.Dim_GL_TxnType_Full_Load`()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_GL_TxnType table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	ARUN		2020-11-09	Created

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_GL_TxnType_Full_Load

EXEC Utility.FromLog 'dbo.Dim_GL_TxnType', 1
SELECT TOP 100 'dbo.Dim_GL_TxnType' Table_Name, * FROM dbo.Dim_GL_TxnType ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_GL_TxnType_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      

      --============================================================================================================= 
      -- Load dbo.Dim_GL_TxnType
      --=============================================================================================================

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_GL_TxnType;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_GL_TxnType CLUSTER BY TxnTypeID
        AS
          SELECT
              Finance_TxnTypes.txntypeid,
              Finance_TxnTypes.txntype,
              Finance_TxnTypes.txndesc,
              Finance_TxnTypes.txntype_categoryid,
              Finance_TxnTypes.statementnote,
              Finance_TxnTypes.customernote,
              Finance_TxnTypes.violatornote,
              Finance_TxnTypes.isautomatic,
              Finance_TxnTypes.adjustmentcategoryid,
              Finance_TxnTypes.levelid,
              Finance_TxnTypes.status,
              Finance_TxnTypes.levelcode,
              Finance_TxnTypes.businessunitid,
              Finance_TxnTypes.createddate,
              Finance_TxnTypes.createduser,
              Finance_TxnTypes.updateddate,
              Finance_TxnTypes.updateduser,
              current_datetime() AS edw_updatedate
            FROM
              LND_TBOS.Finance_TxnTypes
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_GL_TxnType';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL );

      -- Table swap!
      
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_GL_TxnType_NEW', 'EDW_TRIPS.Dim_GL_TxnType');
      --TableSwap is Not Required, using  Create or Replace Table
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_GL_TxnType' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_GL_TxnType
            ORDER BY 2 DESC LIMIT 1000;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL , NULL );
        RAISE USING MESSAGE = error_message; -- Rethrow the error!
      END;
    END;
    /*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_GL_TxnType_Load

EXEC Utility.FromLog 'dbo.Dim_GL_TxnType', 1
SELECT TOP 100 'dbo.Dim_GL_TxnType' Table_Name, * FROM dbo.Dim_GL_TxnType ORDER BY 2


*/
  END;