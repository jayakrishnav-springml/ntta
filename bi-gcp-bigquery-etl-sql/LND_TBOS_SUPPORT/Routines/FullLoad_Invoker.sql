CREATE OR REPLACE PROCEDURE `LND_TBOS_SUPPORT.FullLoad_Invoker`()
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
FullLoad_Invoker- This PROCEDURE invokes actual Fullload PROCEDURE 'On_Demand_Full_Load' 

Parameters : 

===================================================================================================================
Change Log: 
-------------------------------------------------------------------------------------------------------------------
Intial BQ On Demand Full Load Development :Egen 2024-05-15 NEW!

###################################################################################################################
*/
    
    DECLARE last_run_id INT64 DEFAULT 0;
    DECLARE log_source STRING DEFAULT 'FullLoad_Invoker';
    DECLARE log_start_date DATETIME DEFAULT CURRENT_DATETIME('America/Chicago');
    DECLARE logmessage STRING DEFAULT 'FullLoad Invoker started';

    CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', NULL , NULL );

    /*Fetching previous run id used for next runid generation*/
    SET last_run_id =
    (
           SELECT
                  COALESCE(MAX(Fullload_runid),0)
           FROM
                  `LND_TBOS_SUPPORT.Full_Batch_Load`
    );
FOR i IN
		(
			   SELECT
					  stage_table_name      ,
					  stage_full_dataset_name,
					  target_table_name     ,
					  target_dataset_name   ,
                      target_table_columns_list,
                      clustering_columns,
                      key_column,
                      full_or_partial_load_flag
					 
			   FROM
					  `LND_TBOS_SUPPORT.CDC_Full_Load_Config`
			   WHERE
					  full_or_partial_load_flag IN ('F','P')
		)
		DO
	/* Invoking actual Full load procedure*/
			CALL `LND_TBOS_SUPPORT.On_Demand_Full_Load`( i.stage_full_dataset_name||"."||i.stage_table_name, i.target_dataset_name||"."||i.target_table_name,i.target_table_columns_list,i.key_column,last_run_id ,i.clustering_columns,i.full_or_partial_load_flag);
		END FOR;

    SET logmessage= 'FullLoad Invoker Completed Successfully ';  
    CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', NULL , NULL );

EXCEPTION
WHEN ERROR THEN
    BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        SELECT
               @@error.message
        ;
     SET logmessage= 'FullLoad Invoker failed with '|| @@error.message;      
    CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'E', NULL ,NULL );
    END;
END;