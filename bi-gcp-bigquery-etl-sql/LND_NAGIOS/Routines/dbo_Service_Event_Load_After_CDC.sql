CREATE OR REPLACE PROCEDURE `LND_NAGIOS.Service_Event_Load_After_CDC`()
BEGIN
    DECLARE log_source STRING DEFAULT 'LND_NAGIOS.Service_Event_Load_After_CDC';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    BEGIN
      DECLARE row_count INT64;
      DECLARE trace_flag INT64 DEFAULT 0; -- Testing
      SET log_start_date = current_datetime('America/Chicago');
      CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, 'Started load', 'I', NULL, NULL);
      
	  --=============================================================================================================
	  -- Load dbo.Service_Event. This is the main input table for EDW Load.
	  --=============================================================================================================
      INSERT INTO LND_NAGIOS.Service_Event (service_event_id, service_object_id, event_date, service_state, host, service, event_info, perf_data, metric_string, metric_count, lnd_updatedate)
        SELECT
            CAST(concat(right(CAST( status_update_time as STRING FORMAT 'YYYYMMDD'), 6), replace(FORMAT_DATETIME('%H:%M:%S',status_update_time), ':', ''), right(concat('00000', CAST( ss.service_object_id as STRING)), 6)) as INT64) AS service_event_id,
            ss.service_object_id,
            status_update_time AS event_date,
            ss.current_state AS service_state,
            ho.name1 AS host,
            s.display_name AS service,
            left(ss.output, 200) AS event_info,
            nullif(rtrim(ss.perfdata), '') AS perf_data,
            replace(replace(replace(replace(replace(replace(replace(replace(replace(ltrim(CASE
              WHEN rtrim(ss.perfdata) LIKE r'%\n' THEN concat(substr(nullif(rtrim(ss.perfdata), r'\n'), 1, length(rtrim(rtrim(ss.perfdata)))-2), ';')
              WHEN right(nullif(rtrim(ss.perfdata), ''), 1) <> ';' THEN concat(rtrim(ss.perfdata), ';')
              ELSE nullif(rtrim(ss.perfdata), '')
            END), '\'', ''), '; ', ';'), ':', '_'), ' pl=', ';pl='), ' hostgroup_collectors', ';hostgroup_collectors'), ' size=', ';size='), ' ', '_'), '-', '_'), '=_', '=-') AS metric_string,
            length(rtrim(ss.perfdata)) - length(rtrim(replace(ss.perfdata, '=', ''))) AS metric_count,
            ss.lnd_updatedate
          FROM
            LND_NAGIOS_STAGE_CDC.Nagios_ServiceStatus AS ss
            INNER JOIN LND_NAGIOS.Nagios_Services AS s ON ss.service_object_id = s.service_object_id
            INNER JOIN LND_NAGIOS.Nagios_Objects AS ho ON s.host_object_id = ho.object_id
          WHERE (ss.current_check_attempt = ss.max_check_attempts
           OR ss.current_state = 0)
           AND NOT EXISTS (
            SELECT
                1
              FROM
                LND_NAGIOS.Service_Event AS f
              WHERE f.service_object_id = ss.service_object_id
               AND f.event_date = ss.status_update_time
          )
      ;
      SET log_message = 'Loaded LND_NAGIOS.Service_Event from CDC Stage Table';
      CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
	  
      --=============================================================================================================
	  -- Archive history in dbo.nagios_ServiceStatus_HIST
      --=============================================================================================================
      INSERT INTO LND_NAGIOS.Nagios_ServiceStatus_Hist (servicestatus_id, instance_id, service_object_id, status_update_time, output, long_output, perfdata, current_state, has_been_checked, should_be_scheduled, current_check_attempt, max_check_attempts, last_check, next_check, check_type, last_state_change, last_hard_state_change, last_hard_state, last_time_ok, last_time_warning, last_time_unknown, last_time_critical, state_type, last_notification, next_notification, no_more_notifications, notifications_enabled, problem_has_been_acknowledged, acknowledgement_type, current_notification_number, passive_checks_enabled, active_checks_enabled, event_handler_enabled, flap_detection_enabled, is_flapping, percent_state_change, latency, execution_time, scheduled_downtime_depth, failure_prediction_enabled, process_performance_data, obsess_over_service, modified_service_attributes, event_handler, check_command, normal_check_interval, retry_check_interval, check_timeperiod_object_id, lnd_updatedate)
        SELECT
            ss.servicestatus_id,
            ss.instance_id,
            ss.service_object_id,
            ss.status_update_time,
            ss.output,
            ss.long_output,
            ss.perfdata,
            ss.current_state,
            ss.has_been_checked,
            ss.should_be_scheduled,
            ss.current_check_attempt,
            ss.max_check_attempts,
            ss.last_check,
            ss.next_check,
            ss.check_type,
            ss.last_state_change,
            ss.last_hard_state_change,
            ss.last_hard_state,
            ss.last_time_ok,
            ss.last_time_warning,
            ss.last_time_unknown,
            ss.last_time_critical,
            ss.state_type,
            ss.last_notification,
            ss.next_notification,
            ss.no_more_notifications,
            ss.notifications_enabled,
            ss.problem_has_been_acknowledged,
            ss.acknowledgement_type,
            ss.current_notification_number,
            ss.passive_checks_enabled,
            ss.active_checks_enabled,
            ss.event_handler_enabled,
            ss.flap_detection_enabled,
            ss.is_flapping,
            ss.percent_state_change,
            ss.latency,
            ss.execution_time,
            ss.scheduled_downtime_depth,
            ss.failure_prediction_enabled,
            ss.process_performance_data,
            ss.obsess_over_service,
            ss.modified_service_attributes,
            ss.event_handler,
            ss.check_command,
            ss.normal_check_interval,
            ss.retry_check_interval,
            ss.check_timeperiod_object_id,
            ss.lnd_updatedate
          FROM
            LND_NAGIOS_STAGE_CDC.Nagios_ServiceStatus AS ss
          WHERE (ss.current_check_attempt = ss.max_check_attempts
           OR ss.current_state = 0)
           AND NOT EXISTS (
            SELECT
                1
              FROM
                LND_NAGIOS.Nagios_ServiceStatus_Hist AS ssh
              WHERE ssh.service_object_id = ss.service_object_id
               AND ssh.status_update_time = ss.status_update_time
          )
      ;
      SET log_message = 'Loaded LND_NAGIOS.Nagios_ServiceStatus_Hist from CDC Stage Table';
      CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, 'Completed load', 'I', -1, NULL);
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT concat('Error in Service_Event_Load: ', @@error.message);
        CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        RAISE USING MESSAGE = error_message; -- Rethrow the error!
      END;
    END;

/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Service_Event_Load_After_CDC
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
SELECT TOP 1000 * FROM dbo.Service_Event ORDER BY Service_Event_ID DESC
SELECT TOP 1000 * FROM dbo.nagios_servicestatus_HIST ORDER BY status_update_time DESC, service_object_id DESC

--:: Data profile 
SELECT COUNT_BIG(1) nagios_servicestatus_STAGE FROM dbo.nagios_servicestatus_STAGE
SELECT COUNT_BIG(1) Service_Event FROM dbo.Service_Event
SELECT COUNT_BIG(1) nagios_servicestatus_HIST FROM dbo.nagios_servicestatus_HIST
SELECT 'dbo.nagios_servicestatus_STAGE' TableName, CONVERT(DATE, status_update_time) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT service_Object_ID) Dist_Count FROM LND_NAGIOS.dbo.nagios_servicestatus_STAGE GROUP BY CONVERT(DATE, status_update_time) ORDER BY Event_Date desc
SELECT 'dbo.Service_Event' TableName, CONVERT(DATE, Event_Date) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Service_Object_ID) Dist_Count FROM LND_NAGIOS.dbo.Service_Event GROUP BY CONVERT(DATE, Event_Date) ORDER BY Event_Date DESC
SELECT 'dbo.nagios_servicestatus_HIST' TableName, CONVERT(DATE, status_update_time) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT service_Object_ID) Dist_Count FROM LND_NAGIOS.dbo.nagios_servicestatus_HIST GROUP BY CONVERT(DATE, status_update_time) ORDER BY Event_Date desc

--TRUNCATE TABLE dbo.nagios_ServiceStatus_STAGE
--TRUNCATE TABLE EDW_NAGIOS_DEV.dbo.Service_Event
--TRUNCATE TABLE dbo.nagios_ServiceStatus_HIST
--TRUNCATE TABLE Utility.ProcessLog
*/

  END;