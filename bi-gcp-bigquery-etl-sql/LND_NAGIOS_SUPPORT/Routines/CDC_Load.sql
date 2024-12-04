CREATE OR REPLACE PROCEDURE `LND_NAGIOS_SUPPORT.CDC_Load`(IN source_table STRING, IN target_table STRING, IN stage_table STRING, IN key_columns STRING, IN batch_end_date DATETIME, IN previous_run_id INT64, IN batch_name STRING, IN fullday_changedata_flag STRING, overlap_window_in_secs INT64)
BEGIN
/*
#####################################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------------------------
CDC Process Main Procedure
1) This procedure will gnerates the dynamic SQL INSERT and MERGE related to CDC process.
2) executes in run time for  bring latest records from CT tables to Stage tables based on primarykey column and 
merged into Actual landing table 
3) Drived from proc_cdc_invoker based on configuration data form cdc_full_load_config(All cdc tables  metadat and 
other required table names configuration )

Parameters : 
source_table - LND_NAGIOS_Qlik.<__ct tablename> 				:: ct table name from config table
target_table - LND_NAGIOS.<stage_table> 					:: landing table name  from config table
stage_table  - LND_NAGIOS_STAGE_CDC.<target_table>  			:: cdc stagetable name from config table
key_columns  -<col1,col2> 							:: Primary key columns from config table from config table
batch_end_date - Any date time 						:: invoker procedure start date
previous_run_id - Last cdc_run_id for CDC process  			:: Used for identifying start date of next run for the table
cdc_fullload_flag - CDC 							:: need to process full load or CDC currently supports CDC
batch_name -	NAGIOS								:: Which group of table need to process for CDC
fullday_changedata_flag - 	Y/N						:: Whether to cutoff data for only previous day end or run till current datetime
overlap_window_in_secs -Integer defaut 30 secs				:: This value  added to batch start date to dont miss any data 
====================================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------------------------
Intial BQ CDC Development :Egen 2024-05-01	New!

#####################################################################################################################################
*/
    DECLARE current_run_id INT64 DEFAULT 0;
    DECLARE all_input_prameters STRING DEFAULT '';
    DECLARE log_source STRING DEFAULT 'CDC_Load';
    DECLARE log_start_date DATETIME DEFAULT CURRENT_DATETIME('America/Chicago');
    DECLARE logmessage  STRING DEFAULT 'CDC Load started';
    CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', NULL , NULL );    
    
    BEGIN
        DECLARE on_clause STRING DEFAULT '';
        DECLARE update_clause STRING DEFAULT '';
        DECLARE insert_columns_list STRING DEFAULT '';
        DECLARE select_columns_list STRING DEFAULT '';
        DECLARE stage_insert_columns_list STRING DEFAULT '';
        DECLARE insert_values_list STRING DEFAULT '';
        DECLARE merge_query STRING DEFAULT '';
        DECLARE insert_attach STRING DEFAULT '';
        DECLARE run_start_datetime DATETIME DEFAULT CURRENT_DATETIME('America/Chicago');
        DECLARE run_end_datetime   DATETIME;
        DECLARE stage_insert_sql STRING DEFAULT '';
        DECLARE truncate_stage_table STRING DEFAULT '';
        DECLARE batch_start_time DATETIME;
        DECLARE batch_end_time   Datetime DEFAULT
        CASE
        WHEN batch_end_date IS NOT NULL
            AND
            fullday_changedata_flag ='N' THEN
            batch_end_date
       
        ELSE DATETIME_TRUNC(batch_end_date,day)
        END;
        DECLARE batch_start_date_var Datetime;
        DECLARE ct_deltadata_rowcount DEFAULT 0;
        DECLARE stage_tabl_rowcount DEFAULT 0;
        DECLARE lnd_table_rowcount DEFAULT 0;
        DECLARE where_string STRING DEFAULT '';
        DECLARE batch_hrs INT64 DEFAULT 0;
        DECLARE batch_mins INT64 DEFAULT 0;
        DECLARE batch_days INT64 DEFAULT 0;
        DECLARE batch_window_var STRING DEFAULT '';
        DECLARE batch_start_date_query STRING DEFAULT '';
        DECLARE batch_end_date_query STRING DEFAULT '';
	 DECLARE var_stage_insert_values_list STRING DEFAULT NULL;
        DECLARE start_date_count INT64 default 0;
        DECLARE deriving_columns STRING;
        DECLARE error_message STRING DEFAULT @@error.message;
       DECLARE invoker_start_date DATETIME;
       DECLARE ct_change_date_sql STRING DEFAULT "";
       DECLARE change_from_date_var DATETIME;
       DECLARE change_to_date_var DATETIME;
       DECLARE lnd_before_cdc_rowcount_sql STRING DEFAULT "";
       DECLARE lnd_after_cdc_rowcount_sql STRING DEFAULT ""; 
       DECLARE stage_cdc_rowcount_sql STRING DEFAULT ""; 
       DECLARE lnd_dup_rowcount_sql STRING DEFAULT "";
       DECLARE lnd_before_cdc_rowcount_var INT64 DEFAULT 0;
       DECLARE lnd_after_cdc_rowcount_var INT64 DEFAULT 0; 
       DECLARE stage_cdc_rowcount_var INT64 DEFAULT 0; 
       DECLARE lnd_dup_rowcount_var INT64 DEFAULT 0;
       DECLARE ct_row_count_var INT64 DEFAULT 0;
       DECLARE ct_types_sql STRING DEFAULT "";
       DECLARE ct_i_count_var INT64 DEFAULT 0;
       DECLARE ct_u_count_var INT64 DEFAULT 0;
       DECLARE ct_d_count_var INT64 DEFAULT 0;
       DECLARE stage_types_sql STRING DEFAULT "";
       DECLARE stage_i_count_var INT64 DEFAULT 0;
       DECLARE stage_u_count_var INT64 DEFAULT 0;
       DECLARE stage_d_count_var INT64 DEFAULT 0;
       DECLARE lnd_types_sql STRING DEFAULT "";
       DECLARE lnd_i_count_var INT64 DEFAULT 0;
       DECLARE lnd_u_count_var INT64 DEFAULT 0;
       DECLARE lnd_d_count_var INT64 DEFAULT 0;
       DECLARE reload_src_change_check STRING  DEFAULT '';
        
        SET current_run_id =previous_run_id+1;
        SET all_input_prameters = 'source_table'||':'||source_table||','||'target_table'||':'||target_table||','|| 'stage_table' ||':'||stage_table||','||'key_columns' ||':'||key_columns;
            
              IF (key_columns IS NULL
              OR
              source_table IS NULL
              OR
              target_table IS NULL
              OR
              stage_table IS NULL
              OR
              key_columns IS NULL
              )THEN
              SELECT
                     all_input_prameters|| 'All Mandatory in Puts should be passed';              
              RETURN;
              END IF;

       /*Inserting current run log record to cdc_batch_load table */      
        INSERT INTO LND_NAGIOS_SUPPORT.CDC_Batch_Load
           (      cdc_runid            ,
                  cdc_batch_name  ,
                  table_name      ,
                  batch_start_date,
                  batch_end_date  ,
                  batch_window    ,
                  cdc_merge_status,
                  cdc_updatedate  ,
                  change_from_date ,
                  change_to_date ,
                  lnd_before_cdc_rowcount ,
                  ct_rowcount ,
                  ct_i_count ,
                  ct_u_count ,
                  ct_d_count ,                 
                  comments,
                  cdc_merge_end_date
           )
           VALUES
           ( current_run_id,
                  CASE
                         WHEN batch_name IS NULL
                                THEN 'NAGIOS'
                                ELSE batch_name
                  END         ,
                  target_table,
                  NULL     ,
                  NULL     ,
                  NULL     ,
                  'S'      ,
                  CURRENT_DATETIME('America/Chicago'),
                   NULL ,
                   NULL ,
                   NULL ,
                   NULL ,
                   NULL ,
                   NULL ,
                   NULL ,
                  "CDC running for " || target_table||" with Parameters :: "||all_input_prameters,
                  batch_end_date

           );

        /*Fetching  count for succesful runs*/
        SET start_date_count =
        (
               SELECT
                      count(1)
               FROM
                      LND_NAGIOS_SUPPORT.CDC_Batch_Load
               WHERE
                      table_name          = target_table
                      AND cdc_merge_status='C'
        );
  
        IF start_date_count=0 
		THEN
         /*Fetching Minimum src_changedate when previous successful runs not exists  */      
        SET batch_start_date_query ="SELECT MIN(src_changedate) FROM "|| source_table;
        
        EXECUTE IMMEDIATE
            batch_start_date_query INTO batch_start_time;
        ELSE 
        /*Fetching  batch_start_date when previous successful runs exists  */      
          SET batch_start_date_var=(
            SELECT
                DATETIME_SUB(batch_end_date, INTERVAL CASE WHEN overlap_window_in_secs <=0 THEN 60 ELSE overlap_window_in_secs END SECOND )
              FROM
                LND_NAGIOS_SUPPORT.CDC_Batch_Load
              WHERE
                table_name= target_table
                AND cdc_runid = (SELECT MAX(cdc_runid) from LND_NAGIOS_SUPPORT.CDC_Batch_Load 
                         where  table_name=target_table AND cdc_merge_status='C' )
                );
        END IF;

    SET invoker_start_date=batch_end_date;
       
    IF fullday_changedata_flag ='Y' THEN
      SET invoker_start_date=DATETIME_TRUNC(invoker_start_date, DAY);
    END IF; 
        
        SET batch_end_date_query ="SELECT MAX(src_changedate) FROM "|| source_table || " WHERE SRC_ChangeDate < DATETIME'" || invoker_start_date|| "' OR LND_UpdateDate < DATETIME'" ||invoker_start_date ||"'";
        
        EXECUTE IMMEDIATE
            batch_end_date_query INTO batch_end_time;
       /*IF no data  exists in CT tables updating staus and  skiping next steps*/
         IF (start_date_count =0 AND batch_start_time IS NULL) 
              OR  batch_end_time IS NULL
         THEN 
              UPDATE
		   LND_NAGIOS_SUPPORT.CDC_Batch_Load
	       SET    batch_start_date=  CASE
                                   WHEN start_date_count=0
                                          THEN batch_start_time
                                          ELSE batch_start_date_var
                                   END,
                     batch_end_date= batch_end_time ,
                     batch_window= batch_window_var ,
                     cdc_merge_status='I', --If we don't have data in CT table we are skipping merge process and updating cdc_merge_status=I
                     cdc_updatedate  =CURRENT_DATETIME('America/Chicago'),
                     comments="CDC Merge Skipped for "||target_table||' with Parameters :: '||all_input_prameters||" No data exists in CT table ",
                     cdc_merge_end_date=invoker_start_date
	       WHERE
		   cdc_runid     =current_run_id
		   AND table_name=target_table;
         RETURN ;
         END IF;  
            
       SET
	/*generating On clause for dynamic merge*/
	(on_clause, insert_attach) =
	(
		   SELECT
				  (STRING_AGG("T." || split_value || " = S." || split_value, ' AND '), STRING_AGG(split_value,','))
		   FROM
				  UNNEST(SPLIT(key_columns, ",")) AS split_value
	);
       
        SET reload_src_change_check =' SRC_ChangeDate>=(SELECT MIN(SRC_ChangeDate) FROM '||source_table || ' S WHERE '||on_clause||" AND S.LND_UpdateDate >= DATETIME'"||batch_start_date_var ||"' AND S.LND_UpdateDate <DATETIME'"||invoker_start_date || "') AND T.SRC_ChangeDate <=DATETIME'"||batch_end_time||"' ";
   /*Setting time interval filter for current run*/
    SET where_string =
    CASE
    WHEN start_date_count=0 THEN
        "(SRC_ChangeDate >= DATETIME'" ||batch_start_time ||"' AND SRC_ChangeDate <= DATETIME'" ||batch_end_time ||"')" 
        ELSE "((SRC_ChangeDate >= DATETIME'" ||batch_start_date_var ||"' AND SRC_ChangeDate <= DATETIME'" ||batch_end_time ||"') OR ("||reload_src_change_check||" ))" 
    END;
    
	SET batch_end_date =batch_end_time;
       SET batch_days = CAST(Floor(DATETIME_DIFF(batch_end_date,
    CASE
    WHEN start_date_count=0 THEN
        batch_start_time
        ELSE batch_start_date_var
    END,Hour)/24) AS INT64);
	
    SET batch_hrs = CAST(MOD(CAST(DATETIME_DIFF(batch_end_date,
    CASE
    WHEN start_date_count=0 THEN
        batch_start_time
        ELSE batch_start_date_var
    END,Hour) AS NUMERIC),24.0) AS INT64);
	
    SET batch_mins = CAST(MOD(CAST(DATETIME_DIFF(batch_end_date,
    CASE
    WHEN start_date_count=0 THEN
        batch_start_time
        ELSE batch_start_date_var
    END,MINUTE) AS NUMERIC),60.0) AS INT64);
	
       SET batch_window_var=coalesce (batch_days, 0)||' days '|| coalesce (batch_hrs, 0)||' hrs '||coalesce (batch_mins, 0) ||' mins';
    
       SET ct_change_date_sql="SELECT MIN(src_changedate),MAX(src_changedate), count(*) FROM "|| source_table || " T WHERE "||where_string;
       EXECUTE IMMEDIATE ct_change_date_sql INTO change_from_date_var, change_to_date_var, ct_row_count_var;

       SET lnd_before_cdc_rowcount_sql="SELECT COUNT(*) FROM "||target_table;
       EXECUTE IMMEDIATE lnd_before_cdc_rowcount_sql INTO lnd_before_cdc_rowcount_var;

       SET ct_types_sql ="SELECT I,U,D FROM  (SELECT header__change_oper FROM "|| source_table || " T WHERE "|| where_string || ") PIVOT(COUNT(COLLATE(header__change_oper,'')) FOR COLLATE(header__change_oper,'') IN ('I', 'U', 'D'))";
       EXECUTE IMMEDIATE ct_types_sql INTO ct_i_count_var, ct_u_count_var, ct_d_count_var;
    
       /*generating update clause and select column and values list for dynamic merge*/
	SET (update_clause, insert_columns_list, insert_values_list,var_stage_insert_values_list) =
	(
		   SELECT
				  (
				  (
						 SELECT
								REPLACE(STRING_AGG("T." || column_name || "= S." || column_name,','),'S.lnd_updatedate',"current_datetime('America/Chicago')")
						 FROM
								UNNEST(SPLIT(a.target_table_columns_list)) AS column_name
						 WHERE
								column_name NOT IN
								(
									   SELECT
											  split_value
									   FROM
											  UNNEST(SPLIT(key_columns, ",")) AS split_value
								)
				  )
				  , a.target_table_columns_list, REPLACE(a.target_table_columns_list,',lnd_updatedate,',",current_datetime('America/Chicago'),"),stage_insert_values_list)
		   FROM
				  LND_NAGIOS_SUPPORT.CDC_Full_Load_Config a
		   WHERE
				  target_table_name      =SPLIT(target_table, ".")[SAFE_OFFSET(1)]
				  AND target_dataset_name=SPLIT(target_table, ".")[SAFE_OFFSET(0)]
	);
       SET select_columns_list =insert_columns_list;

    IF var_stage_insert_values_list IS NOT NULL
	THEN 
       /*This block  currently not applicable for Nagios now ,In future may be required*/
       /*This block is to read and implemnet transofrmations config from stage_insert_values_list column  */
       SET (stage_insert_columns_list,deriving_columns)=(SELECT (SPLIT(var_stage_insert_values_list ,"::")[SAFE_OFFSET(0)],
                                                               SPLIT(var_stage_insert_values_list ,"::")[SAFE_OFFSET(1)]));
              IF deriving_columns IS NOT NULL
              THEN 
                 FOR j iN (SELECT split_value FROM UNNEST(SPLIT(deriving_columns,',')) AS split_value )
                 DO 
                 SET select_columns_list=REPLACE (select_columns_list,j.split_value||',','')   ; 
                 END FOR;
              END IF;
	--SET stage_insert_columns_list=SPLIT(var_stage_insert_values_list ,"::")[SAFE_OFFSET(0)];
    
       SET insert_columns_list=' ';
	
	ELSE 
	SET stage_insert_columns_list =insert_columns_list;

/*Transforming Boolean data to INT64 */
		FOR j IN
		(
			   SELECT
					  column_name
			   FROM
					  LND_NAGIOS_Qlik.INFORMATION_SCHEMA.COLUMNS a
			   WHERE
					  table_name             =SPLIT(source_table, ".")[SAFE_OFFSET(1)]
					  AND column_name NOT LIKE 'header_%'
					  AND a.data_type        ='BOOL'
		)
		DO
		SET stage_insert_columns_list =
		(
			   SELECT
					  replace (LOWER(stage_insert_columns_list), LOWER(","||j.column_name||','), ",case when " ||j.column_name||" = true THEN 1 ELSE 0 END," )
		);
		END
		FOR;

              SET insert_columns_list=" ("||insert_columns_list||") ";
	END IF;	

	/*Dynamic Truncating stage table query generation*/
	SET truncate_stage_table ="Truncate TABLE " ||stage_table;
	
	/*Dynamic insert stage table query generation*/
	SET stage_insert_sql = "INSERT INTO " ||stage_table||" "||insert_columns_list||" SELECT " ||stage_insert_columns_list ||" FROM (SELECT " ||select_columns_list ||", row_number () over (partition by " || insert_attach ||" order by header__change_seq  desc) rn    FROM " ||source_table || " T WHERE header__change_oper IN ('I','U','D') AND  "||where_string||") Where rn =1";
	
	SELECT stage_insert_sql;

       SET logmessage ='Stage table insert Query '||stage_insert_sql;
       CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', NULL , NULL );

		/*Truncating stage table*/
		EXECUTE IMMEDIATE
			truncate_stage_table;
		/*loading current batch records to Stage table*/
		EXECUTE IMMEDIATE
			stage_insert_sql;

	SET logmessage ='Stage table insert for '||target_table;
       CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', -1 , NULL );	

       SET stage_cdc_rowcount_sql="SELECT COUNT(*) FROM "||stage_table;
       EXECUTE IMMEDIATE stage_cdc_rowcount_sql INTO stage_cdc_rowcount_var;

       IF stage_cdc_rowcount_var >0
       THEN 
		/*Dynamic merge query gneration */
	SET merge_query = "  MERGE INTO " ||target_table ||" T USING    (SELECT *  FROM   " || stage_table ||") S  ON   " ||on_clause ||"   WHEN MATCHED THEN UPDATE SET " ||update_clause ||" WHEN NOT MATCHED THEN  INSERT  " ||insert_columns_list ||"  VALUES   (" ||insert_values_list ||"); ";
		SELECT merge_query
		;

		/*Executing Merge query*/
		EXECUTE IMMEDIATE
			merge_query;

       /*Metrics Related Block starts here*/
       SET lnd_after_cdc_rowcount_sql="SELECT COUNT(*) FROM "||target_table;
       EXECUTE IMMEDIATE lnd_after_cdc_rowcount_sql INTO lnd_after_cdc_rowcount_var;

       SET lnd_dup_rowcount_sql="SELECT count(*) from (SELECT "||key_columns||",count(*) FROM "||target_table||" GROUP BY "
                                   ||key_columns||" HAVING COUNT(*)>1)";
       EXECUTE IMMEDIATE lnd_dup_rowcount_sql INTO lnd_dup_rowcount_var;

       SET stage_types_sql="SELECT I,U,D FROM  (SELECT lnd_updatetype FROM "||
                             stage_table ||" )   PIVOT(COUNT(COLLATE(lnd_updatetype,'')) FOR COLLATE(lnd_updatetype,'') IN ('I', 'U', 'D'))";
       EXECUTE IMMEDIATE stage_types_sql INTO stage_i_count_var, stage_u_count_var, stage_d_count_var;

       SET lnd_types_sql="SELECT I,U,D FROM  (SELECT lnd_updatetype FROM "|| target_table
                             ||" )   PIVOT(COUNT(COLLATE(lnd_updatetype,'')) FOR COLLATE(lnd_updatetype,'') IN ('I', 'U', 'D'))";
       EXECUTE IMMEDIATE lnd_types_sql INTO lnd_i_count_var, lnd_u_count_var, lnd_d_count_var;

	SET logmessage ='Merge Completed  for '||target_table;
       CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', -1 , NULL );	

	SET run_end_datetime =CURRENT_DATETIME('America/Chicago');

	/*Updating status back in cdc_batch_load table*/
	UPDATE
		   LND_NAGIOS_SUPPORT.CDC_Batch_Load
	SET    batch_start_date=  CASE
                         WHEN start_date_count=0
                                THEN batch_start_time
                                ELSE batch_start_date_var
                  END,
              batch_end_date= batch_end_time ,
              batch_window= batch_window_var ,
              cdc_merge_status='C'                                ,
		cdc_updatedate  =CURRENT_DATETIME('America/Chicago'),
              change_from_date = change_from_date_var,
              change_to_date = change_to_date_var ,
              lnd_before_cdc_rowcount = lnd_before_cdc_rowcount_var ,
              lnd_after_cdc_rowcount = lnd_after_cdc_rowcount_var, 
              ct_rowcount = ct_row_count_var ,
              stage_cdc_rowcount= stage_cdc_rowcount_var ,
              lnd_dup_rowcount = lnd_dup_rowcount_var , 
              ct_i_count = ct_i_count_var ,
              ct_u_count = ct_u_count_var,
              ct_d_count = ct_d_count_var,
              stage_i_count = stage_i_count_var,
              stage_u_count = stage_u_count_var,
              stage_d_count = stage_d_count_var,
              lnd_i_count = lnd_i_count_var,
              lnd_u_count = lnd_u_count_var,
              lnd_d_count = lnd_d_count_var,
		comments="CDC Successfully completed at "|| run_end_datetime||" for " || target_table||' with Parameters :: '||all_input_prameters,
              cdc_merge_end_date=invoker_start_date
	WHERE
		   cdc_runid     =current_run_id
		   AND table_name=target_table;

       SET logmessage ='CDC Completed  for '||target_table;
       CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', -1 , NULL );
       ELSE 
       UPDATE
		   LND_NAGIOS_SUPPORT.CDC_Batch_Load
	SET    batch_start_date=  CASE
                         WHEN start_date_count=0
                                THEN batch_start_time
                                ELSE batch_start_date_var
                  END,
              batch_end_date= batch_end_time ,
              batch_window= batch_window_var ,
              cdc_merge_status='I',--If we don't have data in Stage table we are skipping merge process and updating cdc_merge_status=I                               ,
              cdc_updatedate  =CURRENT_DATETIME('America/Chicago'),
           	comments="CDC Merge Skipped for " || target_table||' with Parameters :: '||all_input_prameters||" No change data exists for current run ",
              cdc_merge_end_date=invoker_start_date
	WHERE
		   cdc_runid     =current_run_id
		   AND table_name=target_table;

       SET logmessage ="CDC Merge Skipped for " ||target_table||" NO change data exists for current run ";
       CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', -1 , NULL );
END IF;
EXCEPTION
WHEN ERROR THEN
    SELECT @@error.message;
    
    /*Updating status back in cdc_batch_load table*/
    UPDATE
           LND_NAGIOS_SUPPORT.CDC_Batch_Load
    SET    cdc_merge_status='E'                                ,
           cdc_updatedate  =CURRENT_DATETIME('America/Chicago'),
           comments        ='CDC Failed with error '||@@error.message||" at "||@@error.statement_text|| ' with Parameters :: '||all_input_prameters
    WHERE
           cdc_runid     =current_run_id
           AND table_name=target_table;

     SET logmessage ='Merge Failed  for '||target_table||" "|| @@error.message;
     CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'E', -1 , NULL );

END;
END;