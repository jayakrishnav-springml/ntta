CREATE OR REPLACE PROCEDURE EDW_TRIPS.Dim_CitationStage_Full_Load()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Load dbo.Dim_CitationStage table. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037838	Gouthami		2020-10-14	New!
CHG0040134	Shankar			2021-12-15	Misc. Reporting cosmetics.
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Dim_CitationStage_Full_Load

EXEC Utility.FromLog 'dbo.Dim_CitationStage', 1
SELECT 'LND_TBOS.MIR.TransactionTypes' Table_name,* FROM LND_TBOS.MIR.TransactionTypes ORDER BY 2
SELECT TOP 100 'dbo.Dim_CitationStage' Table_Name, * FROM dbo.Dim_CitationStage ORDER BY 2
###################################################################################################################
*/

    DECLARE log_source STRING DEFAULT 'EDW_TRIPS.Dim_CitationStage_Full_Load';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE row_count INT64;
      SET log_start_date = current_datetime('America/Chicago');
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Started full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));

    --=============================================================================================================
    -- Load dbo.Dim_CitationStage
    --=============================================================================================================

      CREATE  OR REPLACE TABLE EDW_TRIPS.Dim_CitationStage CLUSTER BY CitationStageID
        AS
          SELECT
            TollPlus_Ref_Invoice_Workflow_Stages.stageid AS citationstageid,
            TollPlus_Ref_Invoice_Workflow_Stages.stagecode AS citationstagecode,
            TollPlus_Ref_Invoice_Workflow_Stages.stagename AS citationstagedesc,
            TollPlus_Ref_Invoice_Workflow_Stages.agingperiod,
            TollPlus_Ref_Invoice_Workflow_Stages.graceperiod,
            TollPlus_Ref_Invoice_Workflow_Stages.waiveallfees,
            TollPlus_Ref_Invoice_Workflow_Stages.applyavirate,
            TollPlus_Ref_Invoice_Workflow_Stages.stageorder,
            current_datetime() AS edw_updatedate
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
              -1,
              current_datetime() AS edw_updatedate
          UNION ALL
          SELECT
              0,
              'INVOICE',
              'Invoice',
              0,
              0,
              0,
              0,
              0,
              current_datetime() AS edw_updatedate;
      SET log_message = 'Loaded EDW_TRIPS.Dim_CitationStage';
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, CAST(NULL as STRING));
    
      -- Table Swap Not Required as we are using Create or Replace in BQ
      --CALL EDW_TRIPS_SUPPORT.TableSwap('EDW_TRIPS.Dim_CitationStage_NEW', 'EDW_TRIPS.Dim_CitationStage');
      
      CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date, 'Completed full load', 'I', CAST(NULL as INT64), CAST(NULL as STRING));
      IF trace_flag = 1 THEN
        SELECT
            ' EDW_TRIPS.Dim_CitationStage' AS tablename,
            *
          FROM
            EDW_TRIPS.Dim_CitationStage
        ORDER BY
          2 DESC
        LIMIT 1000
        ;
      END IF;

      EXCEPTION WHEN ERROR THEN
        BEGIN
          DECLARE error_message STRING DEFAULT @@error.message;
          CALL EDW_TRIPS_SUPPORT.ToLog(log_source,log_start_date, error_message, 'E', CAST(NULL as INT64), CAST(NULL as STRING));
          SELECT log_source,log_start_date; -- Replacement for FromLog
          RAISE USING MESSAGE = error_message;
        END;
    END;

/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Dim_CitationStage_Full_Load

EXEC Utility.FromLog 'dbo.Dim_CitationStage', 1
SELECT 'LND_TBOS.MIR.TransactionTypes' Table_name,* FROM LND_TBOS.MIR.TransactionTypes ORDER BY 2
SELECT TOP 100 'dbo.Dim_CitationStage' Table_Name, * FROM dbo.Dim_CitationStage ORDER BY 2

*/
END;