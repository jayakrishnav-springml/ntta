CREATE OR REPLACE PROCEDURE `LND_TBOS_SUPPORT.On_Demand_Full_Load`(IN source_table STRING, IN target_table STRING, IN target_table_columns_list STRING, IN key_columns STRING, IN previous_run_id INT64, IN clustering_columns STRING, IN full_or_partial_load_flag STRING)
BEGIN
/*
#####################################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------------------------
Full Load Process Main Procedure
1) This procedure will gnerates the dynamic SQL CTAS related to Full Load process.
2) executes in run time for  all records from stage tables to actual  landing tables based.
3) Drived from Full Load invoker based on configuration data form cdc_full_load_config

Parameters : 
source_table - LND_TBOS_STAGE_FULL.<target_table> 				:: stage table name from config table
target_table - LND_TBOS.<target_table> 										:: landing table name  from config table
target_table_columns_list 																:: targer table columns list
key_columns							 																	:: targer table key columns list
previous_run_id				 																		:: previous full load runid
clustering_columns				 																:: targer table clustering columns list
full_or_partial_load_flag - Y/N														:: partial  load or complete full load

====================================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------------------------
Intial BQ On-Demand Fullload Development :Egen 2024-05-15	New!

#####################################################################################################################################
	*/

DECLARE current_run_id INT64 DEFAULT 0;
DECLARE all_input_prameters STRING DEFAULT '';
DECLARE log_source STRING DEFAULT 'On_Demand_Full_Load';
DECLARE log_start_date DATETIME DEFAULT CURRENT_DATETIME('America/Chicago');
DECLARE logmessage STRING DEFAULT 'On Demand Full Load started';

	BEGIN
		DECLARE var_rowcount_stage INT64 Default 0;
		DECLARE	var_lnd_rowcount_before_loading INT64 Default 0;
		DECLARE	var_lnd_rowcount_A_D_records INT64 Default 0;
		DECLARE	var_lnd_rowcount_after_loading INT64 Default 0;
		DECLARE rowcount_stage_sql STRING default '';
		DECLARE lnd_rowcount_before_loading_sql STRING  default ''; 
		DECLARE lnd_rowcount_A_D_records_sql STRING default ''; 
		DECLARE lnd_rowcount_after_loading_sql  STRING default ''; 
		DECLARE cluster_clause STRING default '';
		DECLARE CTAS_sql STRING default '';
		DECLARE on_clause STRING default '';
		DECLARE update_clause STRING DEFAULT '';
		DECLARE insert_columns_list STRING DEFAULT '';
    DECLARE insert_values_list STRING DEFAULT '';


	CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date,logmessage,'I', NULL , NULL );

	SET current_run_id =previous_run_id+1;

	SET all_input_prameters = 'source_table'||':'||source_table||',target_table'||':'||target_table||',key_columns' ||':'||key_columns ||',previous_run_id' ||':'||previous_run_id ||',clustering_columns'||':'||clustering_columns ||',paritial_load_flag' ||':'||full_or_partial_load_flag     ;

	
		IF (source_table IS NULL
		OR
		target_table IS NULL
		OR
		previous_run_id IS NULL
		 )THEN
		SELECT
			   all_input_prameters|| ' All Mandatory in Puts should be passed'    ;
		
		RETURN;
	END IF;
	/*Inserting current run log record to cdc_batch_load table */
		INSERT INTO LND_TBOS_SUPPORT.Full_Batch_Load
			   ( Fullload_runid            ,
					  table_name      ,
					  start_date,
					  end_date  ,
					  fullload_updatedate,
					  fullload_status,
					  comments
			   )
			   VALUES
			   ( current_run_id,
					  target_table                    ,
					  CURRENT_DATETIME('America/Chicago'),
					  CURRENT_DATETIME('America/Chicago'),
					  CURRENT_DATETIME('America/Chicago'),
						'S'  ,
						to_json_string(JSON_OBJECT(
													'status', "FullLoad running" ,
													'message','FullLoad running',
													'target_table', target_table,
													'Parameters',all_input_prameters													
													),true
												) 
			   );
			IF clustering_columns IS NOT NULL 
			THEN 
			     SET cluster_clause =' CLUSTER BY '||clustering_columns|| ' ';
			END IF;   
      /*generating On clause for dynamic query*/
			SET	on_clause =
			(
					SELECT
							STRING_AGG("T." || split_value || " = S." || split_value, ' AND ')
					FROM
							UNNEST(SPLIT(key_columns, ",")) AS split_value
			);
			SET rowcount_stage_sql ='SELECT count(1) FROM '||source_table;
			
			EXECUTE IMMEDIATE rowcount_stage_sql INTO var_rowcount_stage;

	IF 	var_rowcount_stage > 0 
	THEN 	 
			SET lnd_rowcount_before_loading_sql ="SELECT count(1) FROM "||target_table||" WHERE lnd_updatetype NOT IN ('D', 'A')";
			
			EXECUTE IMMEDIATE lnd_rowcount_before_loading_sql INTO var_lnd_rowcount_before_loading;
			   
			SET lnd_rowcount_A_D_records_sql ="SELECT count(1) FROM "||target_table||" WHERE lnd_updatetype  IN ('D', 'A')";
			
			EXECUTE IMMEDIATE lnd_rowcount_A_D_records_sql INTO var_lnd_rowcount_A_D_records;
			
		IF full_or_partial_load_flag='P'
		THEN 
					SET (update_clause, insert_columns_list, insert_values_list) =
																							(SELECT
																												(
																												(
																													SELECT
																															STRING_AGG("T." || column_name || "= S." || column_name,',')
																													FROM
																															UNNEST(SPLIT(target_table_columns_list)) AS column_name
																													WHERE
																															column_name NOT IN
																															(
																																	SELECT
																																			split_value
																																	FROM
																																			UNNEST(SPLIT(key_columns, ",")) AS split_value
																															)
																															AND column_name NOT IN ('lnd_updatedate','lnd_updatetype','src_changedate')
																												)
																												, target_table_columns_list, target_table_columns_list));

					SET CTAS_sql = "  MERGE INTO " ||target_table ||" T USING    (SELECT *  FROM   " || source_table ||") S  ON   " ||on_clause ||"   WHEN MATCHED THEN UPDATE SET " ||update_clause ||" WHEN NOT MATCHED THEN  INSERT  (" ||insert_columns_list ||")  VALUES   (" ||insert_values_list ||"); ";
			
			ELSEIF full_or_partial_load_flag ='F'
			THEN
					SET CTAS_sql ="CREATE OR  REPLACE TABLE "||  target_table||cluster_clause||" AS SELECT S.* EXCEPT (lnd_updatedate,lnd_updatetype,src_changedate), COALESCE(coalesce(T.lnd_updatedate,S.lnd_updatedate), CURRENT_DATETIME('America/Chicago')) AS lnd_updatedate,  COALESCE(coalesce(T.lnd_updatetype,S.lnd_updatetype), 'I') AS lnd_updatetype,T.src_changedate FROM "|| source_table||" S  LEFT OUTER JOIN "||target_table ||" T ON " ||on_clause||" UNION ALL SELECT * FROM  "||target_table||"  T WHERE  lnd_updatetype IN ('D','A')";	
		 
			END IF;
			 
			SELECT CTAS_sql;
			
			EXECUTE IMMEDIATE CTAS_sql;	


			SET logmessage= 'On Demand Full Load CTAS execution '||target_table;
			CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', -1 , NULL );
			
			SET lnd_rowcount_after_loading_sql ="SELECT count(1) FROM " ||target_table;
			
		 EXECUTE IMMEDIATE lnd_rowcount_after_loading_sql INTO var_lnd_rowcount_after_loading;
		
			/*Updating metrics in Full_Batch_Load table*/
			UPDATE
					LND_TBOS_SUPPORT.Full_Batch_Load
			SET    fullload_status='C',                             
					fullload_updatedate  =CURRENT_DATETIME('America/Chicago'),
					rowcount_stage=var_rowcount_stage,
					lnd_rowcount_before_loading=var_lnd_rowcount_before_loading,
					lnd_rowcount_A_D_records=var_lnd_rowcount_A_D_records,
					lnd_rowcount_after_loading=var_lnd_rowcount_after_loading,
					end_date=CURRENT_DATETIME('America/Chicago'),
					-- comments        ="FullLoad Successfully completed at "|| CURRENT_DATETIME('America/Chicago')||" for " || target_table||' with Parameters :: '||all_input_prameters
					comments =to_json_string(JSON_OBJECT(
																	'status', "Success" ,
																	'message','Success',
																	'end_time',CURRENT_DATETIME('America/Chicago'),
																	'target_table', target_table,
																	'Parameters',all_input_prameters
																	),true
																) 
			WHERE
					Fullload_runid     =current_run_id
					AND table_name=target_table;

			UPDATE LND_TBOS_SUPPORT.CDC_Full_Load_Config
			SET full_or_partial_load_flag='N'
			WHERE target_table_name=SPLIT(target_table, ".")[SAFE_OFFSET(1)];		

			SET logmessage= 'On Demand Full Load success for table '||target_table;
			CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', NULL , NULL );
	ELSE

			UPDATE LND_TBOS_SUPPORT.CDC_Full_Load_Config
			SET full_or_partial_load_flag='N'
			WHERE target_table_name=SPLIT(target_table, ".")[SAFE_OFFSET(1)];		

      SET logmessage= 'On Demand Full Load Halted,Stage table is empty '||source_table;
			CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', NULL , NULL );
			
			UPDATE
					LND_TBOS_SUPPORT.Full_Batch_Load
			SET    fullload_status='C',                             
					fullload_updatedate  =CURRENT_DATETIME('America/Chicago'),
					rowcount_stage=var_rowcount_stage,
					end_date=CURRENT_DATETIME('America/Chicago'),
					comments =to_json_string(JSON_OBJECT(
																	'status', "Halted" ,
																	'message','Stage table has no rows',
																	'end_time',CURRENT_DATETIME('America/Chicago'),
																	'target_table', target_table,
																	'Parameters',all_input_prameters																	
																	),true
																) 
			WHERE
					Fullload_runid     =current_run_id
					AND table_name=target_table;
		END IF;	
     
	EXCEPTION
	WHEN ERROR THEN
		SELECT
			   @@error.message
		;
		
		/*Updating status back in cdc_batch_load table*/
		UPDATE
			   LND_TBOS_SUPPORT.Full_Batch_Load
		SET    fullload_status='E'                                ,
			   fullload_updatedate  =CURRENT_DATETIME('America/Chicago'),
			   --comments        ='FullLoad Failed '||@@error.message|| ' with Parameters :: '||all_input_prameters
				  comments=to_json_string(JSON_OBJECT(
																	'status', "Fail" ,
																	'message',@@error.message,
																	'end_time',CURRENT_DATETIME('America/Chicago'),
																	'target_table', target_table,
																	'Parameters',all_input_prameters), true
																	)
		WHERE
			   Fullload_runid     =current_run_id
			   AND table_name=target_table
		;
		UPDATE LND_TBOS_SUPPORT.CDC_Full_Load_Config
			SET full_or_partial_load_flag='N'
			WHERE target_table_name=SPLIT(target_table, ".")[SAFE_OFFSET(1)];		
			
	SET logmessage= 'On Demand Full Load failed for table '||target_table||" "||@@error.message;	
  CALL LND_TBOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'E', NULL , NULL );
	END;
END;