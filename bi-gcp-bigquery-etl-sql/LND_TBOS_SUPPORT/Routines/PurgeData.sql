CREATE OR REPLACE PROCEDURE `LND_TBOS_SUPPORT.PurgeData`()

BEGIN 
    DECLARE log_source STRING DEFAULT 'PurgeData';
    DECLARE log_start_date DATETIME DEFAULT CURRENT_DATETIME('America/Chicago');
    DECLARE log_message  STRING DEFAULT 'Started Data Purge';
    DECLARE current_run_id INT64 DEFAULT 0;
    DECLARE source_table_var STRING;

    DECLARE ct_data_delete_sql STRING;
    DECLARE from_date_var DATETIME;
    DECLARE to_date DATETIME;
    DECLARE sql STRING;
    DECLARE min_key_value_var INT64 DEFAULT 0;
    DECLARE max_key_value_var INT64 DEFAULT 1;
    DECLARE rowcount_sql STRING;
    DECLARE row_count_var INT64;

    SET current_run_id=(SELECT COALESCE(MAX(runid),0)+1 FROM LND_TBOS_SUPPORT.PurgeLog);
    
    CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date,log_message, 'I', NULL , NULL );   

    /* Below block invokes Purge Process for tables configured in CDC_Full_Load_Config table  */

    FOR j iN (SELECT source_table_name as table__name,ct_data_retention_days as retention_days,key_column as key_column FROM LND_TBOS_SUPPORT.CDC_Full_Load_Config where purge_run_flag='Y' )
      DO
        BEGIN

          SET source_table_var=j.table__name;
          SET to_date=(SELECT DATETIME_TRUNC(DATETIME_SUB(CURRENT_DATETIME('America/Chicago'), INTERVAL (j.retention_days) DAY), DAY));

          /*Inserting current run log record to PurgeLog table */      

          INSERT INTO LND_TBOS_SUPPORT.PurgeLog(
            runid,
            rundate,
            table_name,
            fromdate,
            todate,
            keycolumn,
            min_key_value,
            max_key_value,
            purged_rowcount,
            purge_status) 
          VALUES 
            ( current_run_id,
              CURRENT_DATETIME('America/Chicago'),
              source_table_var,
              NULL,
              to_date,
              j.key_column,
              NULL,
              NULL,
              NULL,
              'S');

          /* Fetching Minimum src_changedate, min & max key values from CT tables*/

          SET sql=concat("SELECT min(src_changedate),min(",j.key_column,"), max(",j.key_column,") FROM LND_TBOS_Qlik.",source_table_var," WHERE src_changedate< '",to_date,"'");

          EXECUTE IMMEDIATE sql INTO from_date_var,min_key_value_var,max_key_value_var;

          /* Fetching row counts of to be Purged Data */

          SET rowcount_sql=concat("SELECT COUNT(*) FROM LND_TBOS_Qlik.",source_table_var," WHERE src_changedate>= '",from_date_var,"' and src_changedate< '",to_date,"'");
          EXECUTE IMMEDIATE rowcount_sql INTO row_count_var;
         
          /* Deleting records from CT tables prior to ct_data_retention_days data */

          SET ct_data_delete_sql=concat("DELETE FROM LND_TBOS_Qlik.",source_table_var," WHERE src_changedate>= '",from_date_var,"' and src_changedate< '",to_date,"'");
          EXECUTE IMMEDIATE ct_data_delete_sql;

          SET log_message = CONCAT("Deleted",source_table_var," records from ",from_date_var," to ",DATETIME_SUB(DATETIME_TRUNC(to_date, day),INTERVAL 1 SECOND));
          CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date,log_message, 'I', NULL , NULL );   

	        /* Updating status back to PurgeLog table */

          UPDATE
              LND_TBOS_SUPPORT.PurgeLog
          SET   purge_status= 'C'                             ,
                rundate  = CURRENT_DATETIME('America/Chicago'),
                from_date= from_date_var                      ,
                min_key_value= min_key_value_var              ,
                max_key_value= max_key_value_var              ,
                row_count= row_count_var

            WHERE
                  runid     =current_run_id
                  AND table_name=source_table_var
          ; 

        
        EXCEPTION WHEN ERROR THEN   
    	  /* Updating status back to PurgeLog table in case of any error occurs */

        UPDATE
              LND_TBOS_SUPPORT.PurgeLog
        SET   purge_status='E',
              rundate  =CURRENT_DATETIME('America/Chicago')
        WHERE
              runid     =current_run_id
              AND table_name=source_table_var
        ;
        SET log_message ='Purge Failed  for '||source_table_var||" "|| @@error.message;
        CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date,log_message, 'E', -1 , NULL );
      END;        
      
    END FOR;      

    SET log_message = CONCAT('Purge process completed');

    CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date,log_message, 'I', NULL , NULL );   
     EXCEPTION
    WHEN ERROR THEN
      BEGIN
          DECLARE error_message STRING DEFAULT @@error.message;
          SELECT @@error.message ;
          SET log_message =  'Purge Failed: '|| @@error.message;
          CALL LND_TBOS_SUPPORT.ToLog (log_source, log_start_date,log_message, 'E', NULL , NULL );
      END;  
  
  END;
