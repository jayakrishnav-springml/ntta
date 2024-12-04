CREATE OR REPLACE PROCEDURE `LND_NAGIOS_SUPPORT.Host_Event_CDC_load`(IN batch_end_date DATETIME, IN previous_run_id INT64, IN fullday_changedata_flag STRING)
BEGIN
/*
#####################################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------------------------
CDC Process Main Procedure
1) This procedure will generates the dynamic SQL INSERT and MERGE related to CDC process.
2) executes in run time for  bring latest records from CT tables to Stage tables based on primarykey column and 
merged into Actual landing table 
3) Drived from proc_cdc_invoker based on configuration data form cdc_full_load_config(All cdc tables  metadat and 
other required table names configuration )

Parameters : 
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
	DECLARE  cdc_run_flag STRING;
	DECLARE  batch_name STRING;	
    DECLARE all_input_prameters STRING DEFAULT '';
    DECLARE log_source STRING DEFAULT 'HostStatus_CDC_load';
    DECLARE log_start_date DATETIME DEFAULT CURRENT_DATETIME('America/Chicago');
    DECLARE logmessage  STRING DEFAULT 'HostStatus CDC Load started';
    

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
        DECLARE batch_hrs INT64 DEFAULT 0;
        DECLARE batch_mins INT64 DEFAULT 0;
        DECLARE batch_days INT64 DEFAULT 0;
        DECLARE batch_window_var STRING DEFAULT '';
        DECLARE batch_start_date_query STRING DEFAULT '';
        DECLARE start_date_count INT64 default 0;
        DECLARE error_message STRING DEFAULT @@error.message;
       DECLARE key_columns STRING DEFAULT '';
       DECLARE invoker_start_date DATETIME; 
       DECLARE change_from_date_var DATETIME;
       DECLARE change_to_date_var DATETIME;
       DECLARE lnd_before_cdc_rowcount_var INT64 DEFAULT 0;
       DECLARE lnd_after_cdc_rowcount_var INT64 DEFAULT 0; 
       DECLARE stage_cdc_rowcount_var INT64 DEFAULT 0; 
       DECLARE lnd_dup_rowcount_var INT64 DEFAULT 0;
       DECLARE ct_row_count_var INT64 DEFAULT 0;
       DECLARE ct_i_count_var INT64 DEFAULT 0;
       DECLARE ct_u_count_var INT64 DEFAULT 0;
       DECLARE ct_d_count_var INT64 DEFAULT 0;
       DECLARE stage_i_count_var INT64 DEFAULT 0;
       DECLARE stage_u_count_var INT64 DEFAULT 0;
       DECLARE stage_d_count_var INT64 DEFAULT 0;
       DECLARE lnd_i_count_var INT64 DEFAULT 0;
       DECLARE lnd_u_count_var INT64 DEFAULT 0;
       DECLARE lnd_d_count_var INT64 DEFAULT 0;
       DECLARE reload_src_change_check STRING  DEFAULT '';
       DECLARE run_end_datetime   DATETIME;
       DECLARE overlap_window_in_secs INT64 DEFAULT 0;

       
    CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', NULL , NULL );   
 
	SET (cdc_run_flag, key_columns,overlap_window_in_secs)   =( 
              SELECT
					(cdc_run_flag, key_column,overlap_window_in_secs)   
			   FROM
					  `LND_NAGIOS_SUPPORT.CDC_Full_Load_Config`
			   WHERE
					  target_table_name='Host_Event');

	IF cdc_run_flag ='Y'	
  THEN
        SET current_run_id =previous_run_id+1;

        SET all_input_prameters = 'source_table'||': LND_NAGIOS_Qlik.nagios_hoststatus__ct,'||'target_table'||': LND_NAGIOS.Host_Event,'|| 'stage_table' ||': LND_NAGIOS_STAGE_CDC.Nagios_HostStatus,'||'batch_end_date' ||':'||batch_end_date||','||'previous_run_id' ||':'||previous_run_id  ||':'||'fullday_changedata_flag :'  ||fullday_changedata_flag ;
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
                  'Host Event',
                  'LND_NAGIOS.Host_Event',
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
                  "CDC running for LND_NAGIOS.Host_Event with Parameters :: "||all_input_prameters,
                  batch_end_date
           );

        /*Fetching  count for successful runs*/
        SET start_date_count =
        (
               SELECT
                      count(1)
               FROM
                      LND_NAGIOS_SUPPORT.CDC_Batch_Load
               WHERE
                      table_name          = 'LND_NAGIOS.Host_Event'
                      AND cdc_merge_status='C'
        );
   /*Fetching Minimum src_changedate when previous successful runs not exists  */
        IF start_date_count=0 
		THEN
        SET batch_start_time =(SELECT MIN(src_changedate) FROM LND_NAGIOS_Qlik.nagios_hoststatus__ct);
        
        ELSE 
    /*Fetching  batch_start_date when previous scucessful runs exists  */      
        SET batch_start_date_var=(
            SELECT
                DATETIME_SUB(batch_end_date, INTERVAL CASE WHEN overlap_window_in_secs <=0 THEN 60 ELSE overlap_window_in_secs END SECOND )
            FROM
            LND_NAGIOS_SUPPORT.CDC_Batch_Load
            WHERE
            table_name= "LND_NAGIOS.Host_Event"
            AND cdc_runid = (SELECT MAX(cdc_runid) from LND_NAGIOS_SUPPORT.CDC_Batch_Load 
                        where  table_name="LND_NAGIOS.Host_Event" AND cdc_merge_status='C' )
            );
        END IF;
   
    SET invoker_start_date=batch_end_date;
    IF fullday_changedata_flag ='Y' THEN
      SET invoker_start_date=DATETIME_TRUNC(invoker_start_date, DAY);
    END IF; 
    SET batch_end_time =(SELECT MAX(src_changedate) FROM LND_NAGIOS_Qlik.nagios_hoststatus__ct WHERE SRC_ChangeDate < CAST(invoker_start_date AS DATETIME) OR LND_UpdateDate < CAST(invoker_start_date AS DATETIME));
       /*IF no data  exists in CT tables updating status and  skipping next steps*/

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
                     comments="CDC Merge Skipped for LND_NAGIOS.Host_Event with Parameters :: "||all_input_prameters||" NO data exists in CT table ",
                     cdc_merge_end_date=invoker_start_date
	       WHERE
		   cdc_runid     =current_run_id
		   AND table_name="LND_NAGIOS.Host_Event";
         RETURN ;
         END IF;  

        SET reload_src_change_check =" SRC_ChangeDate>=(SELECT MIN(SRC_ChangeDate) FROM LND_NAGIOS_Qlik.nagios_hoststatus__ct S WHERE S.LND_UpdateDate >= DATETIME'"||batch_start_date_var ||"' AND S.LND_UpdateDate <DATETIME'"||invoker_start_date || "') AND T.SRC_ChangeDate <=DATETIME'"||batch_end_time||"' ";
    
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

    SET (change_from_date_var, change_to_date_var, ct_row_count_var)=(
        SELECT (MIN(src_changedate),MAX(src_changedate), count(*)) FROM LND_NAGIOS_Qlik.nagios_hoststatus__ct T WHERE 
        CASE
        WHEN start_date_count=0 THEN
            (SRC_ChangeDate >=  batch_start_time AND SRC_ChangeDate <=  batch_end_time) 
        ELSE 
            ((SRC_ChangeDate >=  batch_start_date_var AND SRC_ChangeDate <=  batch_end_time ) OR 
            (SRC_ChangeDate>=(SELECT MIN(SRC_ChangeDate) FROM LND_NAGIOS_Qlik.nagios_hoststatus__ct S 
            WHERE S.LND_UpdateDate >=  batch_start_date_var AND S.LND_UpdateDate <  invoker_start_date )
            AND SRC_ChangeDate <= batch_end_time)) 
        END)
        ;


    SET lnd_before_cdc_rowcount_var = (SELECT COUNT(*) FROM LND_NAGIOS.Host_Event);

        SET (ct_i_count_var, ct_u_count_var, ct_d_count_var)=(SELECT (I,U,D)  FROM  (SELECT header__change_oper FROM LND_NAGIOS_Qlik.nagios_hoststatus__ct T WHERE 
        CASE
    WHEN start_date_count=0 THEN
        (SRC_ChangeDate >=  batch_start_time AND SRC_ChangeDate <=  batch_end_time) 
    ELSE 
        ((SRC_ChangeDate >=  batch_start_date_var AND SRC_ChangeDate <=  batch_end_time ) OR 
        (SRC_ChangeDate>=(SELECT MIN(SRC_ChangeDate) FROM LND_NAGIOS_Qlik.nagios_hoststatus__ct S 
        WHERE S.LND_UpdateDate >=  batch_start_date_var AND S.LND_UpdateDate <  invoker_start_date )
         AND SRC_ChangeDate <= batch_end_time)) 
    END) 
    PIVOT(COUNT(COLLATE(header__change_oper,'')) FOR COLLATE(header__change_oper,'') IN ('I', 'U', 'D'))
    );


	TRUNCATE TABLE LND_NAGIOS_STAGE_CDC.Nagios_HostStatus;
		
		
	INSERT INTO LND_NAGIOS_STAGE_CDC.Nagios_HostStatus
    SELECT
    hoststatus.hoststatus_id,
    hoststatus.instance_id,
    hoststatus.host_object_id,
    hoststatus.status_update_time,
    hoststatus.output,
    hoststatus.long_output,
    hoststatus.perfdata,
    hoststatus.current_state,
    hoststatus.has_been_checked,
    hoststatus.should_be_scheduled,
    hoststatus.current_check_attempt,
    hoststatus.max_check_attempts,
    hoststatus.last_check,
    hoststatus.next_check,
    hoststatus.check_type,
    hoststatus.last_state_change,
    hoststatus.last_hard_state_change,
    hoststatus.last_hard_state,
    hoststatus.last_time_up,
    hoststatus.last_time_down,
    hoststatus.last_time_unreachable,
    hoststatus.state_type,
    hoststatus.last_notification,
    hoststatus.next_notification,
    hoststatus.no_more_notifications,
    hoststatus.notifications_enabled,
    hoststatus.problem_has_been_acknowledged,
    hoststatus.acknowledgement_type,
    hoststatus.current_notification_number,
    hoststatus.passive_checks_enabled,
    hoststatus.active_checks_enabled,
    hoststatus.event_handler_enabled,
    hoststatus.flap_detection_enabled,
    hoststatus.is_flapping,
    hoststatus.percent_state_change,
    hoststatus.latency,
    hoststatus.execution_time,
    hoststatus.scheduled_downtime_depth,
    hoststatus.failure_prediction_enabled,
    hoststatus.process_performance_data,
    hoststatus.obsess_over_host,
    hoststatus.modified_host_attributes,
    hoststatus.event_handler,
    hoststatus.check_command,
    hoststatus.normal_check_interval,
    hoststatus.retry_check_interval,
    hoststatus.check_timeperiod_object_id,
    hoststatus.lnd_updatedate,
    hoststatus.lnd_updatetype, 
    hoststatus.src_changedate
  FROM
    (
      SELECT
          nagios_hoststatus__ct.hoststatus_id,
          nagios_hoststatus__ct.instance_id,
          nagios_hoststatus__ct.host_object_id,
          nagios_hoststatus__ct.status_update_time,
          CAST( nagios_hoststatus__ct.output as STRING) AS output,
          CAST( nagios_hoststatus__ct.long_output as STRING) AS long_output,
          CAST( nagios_hoststatus__ct.perfdata as STRING) AS perfdata,
          nagios_hoststatus__ct.current_state,
          nagios_hoststatus__ct.has_been_checked,
          nagios_hoststatus__ct.should_be_scheduled,
          nagios_hoststatus__ct.current_check_attempt,
          nagios_hoststatus__ct.max_check_attempts,
          nagios_hoststatus__ct.last_check,
          nagios_hoststatus__ct.next_check,
          nagios_hoststatus__ct.check_type,
          nagios_hoststatus__ct.last_state_change,
          nagios_hoststatus__ct.last_hard_state_change,
          nagios_hoststatus__ct.last_hard_state,
          nagios_hoststatus__ct.last_time_up,
          nagios_hoststatus__ct.last_time_down,
          nagios_hoststatus__ct.last_time_unreachable,
          nagios_hoststatus__ct.state_type,
          nagios_hoststatus__ct.last_notification,
          nagios_hoststatus__ct.next_notification,
          nagios_hoststatus__ct.no_more_notifications,
          nagios_hoststatus__ct.notifications_enabled,
          nagios_hoststatus__ct.problem_has_been_acknowledged,
          nagios_hoststatus__ct.acknowledgement_type,
          nagios_hoststatus__ct.current_notification_number,
          nagios_hoststatus__ct.passive_checks_enabled,
          nagios_hoststatus__ct.active_checks_enabled,
          nagios_hoststatus__ct.event_handler_enabled,
          nagios_hoststatus__ct.flap_detection_enabled,
          nagios_hoststatus__ct.is_flapping,
          nagios_hoststatus__ct.percent_state_change,
          nagios_hoststatus__ct.latency,
          nagios_hoststatus__ct.execution_time,
          nagios_hoststatus__ct.scheduled_downtime_depth,
          nagios_hoststatus__ct.failure_prediction_enabled,
          nagios_hoststatus__ct.process_performance_data,
          nagios_hoststatus__ct.obsess_over_host,
          nagios_hoststatus__ct.modified_host_attributes,
          CAST( nagios_hoststatus__ct.event_handler as STRING) AS event_handler,
          CAST( nagios_hoststatus__ct.check_command as STRING) AS check_command,
          nagios_hoststatus__ct.normal_check_interval,
          nagios_hoststatus__ct.retry_check_interval,
          nagios_hoststatus__ct.check_timeperiod_object_id,
          current_datetime() AS lnd_updatedate,
          nagios_hoststatus__ct.lnd_updatetype, 
          nagios_hoststatus__ct.src_changedate,
          row_number() OVER (PARTITION BY nagios_hoststatus__ct.host_object_id, nagios_hoststatus__ct.status_update_time ORDER BY nagios_hoststatus__ct.header__change_seq DESC) AS lastchangeseq
        FROM
          LND_NAGIOS_Qlik.nagios_hoststatus__ct
        WHERE nagios_hoststatus__ct.header__change_oper IN(
          'I', 'U'
        )
		AND 
    CASE
    WHEN start_date_count=0 THEN
        (SRC_ChangeDate >=  batch_start_time AND SRC_ChangeDate <=  batch_end_time) 
    ELSE 
        ((SRC_ChangeDate >=  batch_start_date_var AND SRC_ChangeDate <=  batch_end_time ) OR 
        (SRC_ChangeDate>=(SELECT MIN(SRC_ChangeDate) FROM LND_NAGIOS_Qlik.nagios_hoststatus__ct S 
        WHERE S.LND_UpdateDate >=  batch_start_date_var AND S.LND_UpdateDate <  invoker_start_date )
         AND SRC_ChangeDate <= batch_end_time)) 
    END


    ) AS hoststatus
    WHERE hoststatus.lastchangeseq = 1;
	
	
	SET logmessage ='Stage table insert for LND_NAGIOS.Host_Event, batch_start_date:'||batch_start_date_var||',batch_end_date :'||batch_end_time||',start_date_count:'||start_date_count;
    CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', -1 , NULL );	

    CALL LND_NAGIOS.Host_Event_Load_After_CDC();
    /*Metrics Related Block starts here*/
    SET stage_cdc_rowcount_var= (SELECT COUNT(*) FROM LND_NAGIOS_STAGE_CDC.Nagios_HostStatus);
    SET lnd_after_cdc_rowcount_var=(SELECT COUNT(*) FROM LND_NAGIOS.Host_Event);
    SET lnd_dup_rowcount_var=(SELECT count(*) from (SELECT host_event_id,count(*) FROM LND_NAGIOS.Host_Event GROUP BY 
                              host_event_id HAVING COUNT(*)>1));
    SET (stage_i_count_var, stage_u_count_var, stage_d_count_var)=(SELECT (I,U,D) FROM  (SELECT lnd_updatetype FROM LND_NAGIOS_STAGE_CDC.Nagios_HostStatus ) PIVOT(COUNT(COLLATE(lnd_updatetype,'')) FOR COLLATE(lnd_updatetype,'') IN ('I', 'U', 'D')));
    SET (lnd_i_count_var, lnd_u_count_var, lnd_d_count_var)=(SELECT (I,U,D) FROM  (SELECT lnd_updatetype FROM LND_NAGIOS.Host_Event ) PIVOT(COUNT(COLLATE(lnd_updatetype,'')) FOR COLLATE(lnd_updatetype,'') IN ('I', 'U', 'D')));


	   
	SET logmessage ='Host_Event_Load_After_CDC procedure invoked';
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
		      comments ="CDC Successfully completed at "||  run_end_datetime||" for LND_NAGIOS.Host_Event"||' with Parameters :: '||all_input_prameters,
              cdc_merge_end_date=invoker_start_date
	WHERE
		   cdc_runid     =current_run_id
		   AND table_name='LND_NAGIOS.Host_Event'
	;

       SET logmessage ='CDC Completed  for LND_NAGIOS.Host_Event';
       CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'I', -1 , NULL );
END
IF;
EXCEPTION
WHEN ERROR THEN
    SELECT
           @@error.message
    ;
    
    /*Updating status back in cdc_batch_load table*/
    UPDATE
           LND_NAGIOS_SUPPORT.CDC_Batch_Load
    SET    cdc_merge_status='E'                                ,
           cdc_updatedate  =CURRENT_DATETIME('America/Chicago'),
           comments        ='CDC Failed with error '||@@error.message||" at "||@@error.statement_text|| ' with Parameters :: '||all_input_prameters
    WHERE
           cdc_runid     =current_run_id
           AND table_name='LND_NAGIOS.Host_Event'
    ;
     SET logmessage ='CDC for LND_NAGIOS.Host_Event'|| @@error.message;
     CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date,logmessage, 'E', -1 , NULL );

END;