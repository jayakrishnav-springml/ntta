CREATE OR REPLACE PROCEDURE EDW_TRIPS.Dim_InvoiceStage_Full_Load()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_InvoiceStage table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Ranjith Nair	2020-10-14	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_InvoiceStage_Full_Load

EXEC Utility.FromLog 'dbo.Dim_InvoiceStage', 1
SELECT TOP 100 'dbo.Dim_InvoiceStage' Table_Name, * FROM dbo.Dim_InvoiceStage ORDER BY 2
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_InvoiceStage_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', NULL, NULL);

		--=============================================================================================================
		-- Load dbo.Dim_InvoiceStage
		--=============================================================================================================
		      

      --DROP TABLE IF EXISTS EDW_TRIPS.Dim_InvoiceStage;
      CREATE OR REPLACE TABLE EDW_TRIPS.Dim_InvoiceStage CLUSTER BY InvoiceStageID
        AS
          SELECT
              TollPlus_Ref_Invoice_Workflow_Stages.stageid AS invoicestageid,
              TollPlus_Ref_Invoice_Workflow_Stages.stagecode AS invoicestagecode,
              TollPlus_Ref_Invoice_Workflow_Stages.stagename AS invoicestagedesc,
              TollPlus_Ref_Invoice_Workflow_Stages.agingperiod,
              TollPlus_Ref_Invoice_Workflow_Stages.graceperiod,
              TollPlus_Ref_Invoice_Workflow_Stages.waiveallfees,
              TollPlus_Ref_Invoice_Workflow_Stages.applyavirate,
              TollPlus_Ref_Invoice_Workflow_Stages.stageorder,
              current_datetime() AS edw_updateddate
            FROM
              LND_TBOS.TollPlus_Ref_Invoice_Workflow_Stages
          UNION ALL
          SELECT
              -1,
              'Unknown',
              'Unknown',
              0,
              0,
              0,
              0,
              0,
              current_datetime() AS edw_updateddate
      ;
      SET log_message = 'Loaded EDW_TRIPS.Dim_InvoiceStage';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
      -- Table swap!
      --TableSwap is Not Required, using  Create or Replace Table
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_InvoiceStage_NEW', 'EDW_TRIPS.Dim_InvoiceStage');
      
      
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', NULL, NULL);
      ## Show results

      IF trace_flag = 1 THEN
        ##CALL utility.fromlog(log_source, log_start_date);
        SELECT log_source,log_start_date;
      END IF;
      IF trace_flag = 1 THEN
        SELECT
            'EDW_TRIPS.Dim_InvoiceStage' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_InvoiceStage
            ORDER BY 2 DESC LIMIT 1000;
      END IF;
      
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source,log_start_date, error_message, 'E', NULL, NULL);       
        RAISE USING MESSAGE = error_message; -- Rethrow the error!
      END;
    END;
    /*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_InvoiceStage_Full_Load

EXEC Utility.FromLog 'dbo.Dim_InvoiceStage', 1
SELECT 'LND_TBOS.MIR.ReasonCodes' Table_name,* FROM LND_TBOS.MIR.ReasonCodes ORDER BY 2
SELECT TOP 100 'dbo.Dim_InvoiceStage' Table_Name, * FROM dbo.Dim_InvoiceStage ORDER BY 2

*/

  END;