CREATE OR REPLACE PROCEDURE LND_TBOS_SUPPORT.CDC_Invoker(IN batch_name STRING, IN fullday_changedata_flag STRING, IN cutoff_date DATETIME)
BEGIN
/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
CDC Process Invoker - This PROCEDURE invokes actual CDC PROCEDURE 'CDC_Load' based ON parameters CDC process will 
be invoked

Parameters : 
batch_name -  'TRIPS' Process ALL CDC tables AS part OF master CDC,
			  'TRIPS_Finance_GL' Process Finance report related GROUP tables
fullday_changedata_flag - Y FOR getiing till previous day end  cutoff DATA only
						N FOR getiing till DATA upto invoker start date (Current_datetime) 
cutoff_date - batch  end date - CDC proecess merge data upto this date.						
===================================================================================================================
Change Log: 
-------------------------------------------------------------------------------------------------------------------
Intial BQ CDC Development :Egen 2024-05-01 NEW!

###################################################################################################################
*/	
    DECLARE batch_end_date DATETIME DEFAULT current_Datetime('America/Chicago');
    DECLARE last_run_id INT64 DEFAULT 0;
		DECLARE log_source STRING DEFAULT 'CDC_Invoker';
		DECLARE log_start_date DATETIME DEFAULT CURRENT_DATETIME('America/Chicago');
		DECLARE logmessage  STRING DEFAULT 'CDC invoker started';
		CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', NULL , NULL );

	/* Checking if cutoff_date is Provided and Updating Flags based on it */
	IF cutoff_date is not NULL
	THEN 
		SET fullday_changedata_flag = 'N';
		SET batch_end_date = cutoff_date;
		SET  logmessage = concat( 'CDC invoker Called with cutoff_date , Setting fullday_changedata_flag to N and Limiting Data Merge upto ', Cast(batch_end_date as String ));
		CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', NULL , NULL );
	END IF;

    /*Fetching previous run id used for next runid generation*/
    SET last_run_id =
    (
           SELECT
                  COALESCE(MAX(cdc_RunID),0)
           FROM
                  LND_TBOS_SUPPORT.CDC_Batch_Load
    );

    /*Below code block Invokes CDC process for all the table part of Master CDC process*/
    IF batch_name ='TRIPS' THEN
		FOR i IN
		(
			   SELECT
					  source_table_name     ,
					  source_dataset_name   ,
					  stage_table_name      ,
					  stage_cdc_dataset_name,
					  target_table_name     ,
					  target_dataset_name   ,
					  key_column            ,
					  overlap_window_in_secs
			   FROM
					  `LND_TBOS_SUPPORT.CDC_Full_Load_Config`
			   WHERE
					  cdc_run_flag='Y' order by target_table_name asc
		)
		DO
	 /* Invoking actual CDC load procedure*/
			CALL `LND_TBOS_SUPPORT.CDC_Load`( i.source_dataset_name||"."||i.source_table_name, i.target_dataset_name||"."||i.target_table_name, i.stage_cdc_dataset_name||"."||i.stage_table_name, i. key_column, batch_end_date, last_run_id, batch_name, fullday_changedata_flag, i.overlap_window_in_secs );
		END FOR;

	 /*Below code block Invokes CDC process for GL tables*/
		ELSEIF batch_name ='TRIPS_Finance_GL' THEN
		FOR i IN
		(
				   SELECT
						  source_table_name     ,
						  source_dataset_name   ,
						  stage_table_name      ,
						  stage_cdc_dataset_name,
						  target_table_name     ,
						  target_dataset_name   ,
						  key_column            ,
					    overlap_window_in_secs
				   FROM
						  `LND_TBOS_SUPPORT.CDC_Full_Load_Config`
				   WHERE
						  cdc_run_flag       ='Y'
						  AND cdc_batch_name =batch_name
					 order by target_table_name asc
			)
			DO
  /* Invoking actual CDC load procedure*/
       CALL `LND_TBOS_SUPPORT.CDC_Load`( i.source_dataset_name||"."||i.source_table_name, i.target_dataset_name||"."||i.target_table_name, i.stage_cdc_dataset_name||"."||i.stage_table_name, i. key_column, batch_end_date, last_run_id, batch_name, fullday_changedata_flag, i.overlap_window_in_secs);
		END FOR;
		END IF;

	SET logmessage = 'CDC invoker Sucessfully Completed';
	CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date, 'CDC invoker Sucessfully Completed', 'I', NULL , NULL );

EXCEPTION
WHEN ERROR THEN
    BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        SELECT @@error.message ;
		SET logmessage =  'CDC invoker Failed '|| @@error.message;
		CALL LND_TBOS_SUPPORT.ToLog (log_source, log_start_date,logmessage, 'E', NULL , NULL );
    END;
END;