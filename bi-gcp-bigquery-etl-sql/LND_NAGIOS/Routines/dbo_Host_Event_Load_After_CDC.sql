CREATE OR REPLACE PROCEDURE `LND_NAGIOS.Host_Event_Load_After_CDC`()
BEGIN
    DECLARE log_source STRING DEFAULT 'LND_NAGIOS.Host_Event_Load_After_CDC';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    BEGIN
      DECLARE row_count INT64;
      DECLARE trace_flag INT64 DEFAULT 0;  -- Testing
      SET log_start_date = current_datetime('America/Chicago');
      CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, 'Started load', 'I', NULL, NULL);
      
      --=============================================================================================================
      -- Load dbo.Host_Event. This is the main input table for EDW Load.
      --=============================================================================================================
      INSERT INTO LND_NAGIOS.Host_Event (host_event_id, host_object_id, event_date, host_state, host, event_info, perf_data, metric_string, metric_count, lnd_updatedate)
        SELECT
            CAST(concat(right(CAST( status_update_time as STRING FORMAT 'YYYYMMDD'), 6), replace(FORMAT_DATETIME('%H:%M:%S',status_update_time), ':', ''), right(concat('00000', CAST(host_object_id AS STRING)), 6)) as INT64) AS host_event_id,
            hs.host_object_id,
            status_update_time AS event_date,
            hs.current_state AS host_state,
            ho.name1 AS host,
            left(hs.output, 200) AS event_info,
            nullif(rtrim(hs.perfdata), '') AS perf_data,
            replace(replace(replace(replace(replace(replace(replace(replace(replace(ltrim(CASE
              WHEN rtrim(hs.perfdata) LIKE r'%\n' THEN concat(substr(nullif(rtrim(hs.perfdata), r'\n'), 1, length(rtrim(rtrim(hs.perfdata)))-2), ';')
              WHEN right(nullif(rtrim(hs.perfdata), ''), 1) <> ';' THEN concat(rtrim(hs.perfdata), ';')
              ELSE nullif(rtrim(hs.perfdata), '')
            END), '\'', ''), '; ', ';'), ':', '_'), ' pl=', ';pl='), ' size=', ';size='), '-', '_'), '=_', '=-'), ' ', '_'), '_rtmax=', ';rtmax=') AS metric_string,
            length(rtrim(hs.perfdata)) - length(rtrim(replace(hs.perfdata, '=', ''))) AS metric_count,
            hs.lnd_updatedate
          FROM
            LND_NAGIOS_STAGE_CDC.Nagios_HostStatus AS hs
            INNER JOIN LND_NAGIOS.Nagios_Objects AS ho ON hs.host_object_id = ho.object_id
          WHERE (hs.current_check_attempt = hs.max_check_attempts
           OR hs.current_state = 0)
           AND NOT EXISTS (
            SELECT
                1
              FROM
                LND_NAGIOS.Host_Event AS src
              WHERE src.host_object_id = hs.host_object_id
               AND src.event_date = hs.status_update_time
          )
      ;
      SET log_message = 'Loaded LND_NAGIOS.Host_Event from CDC Stage Table';
      CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      
	  --=============================================================================================================
	  -- Archive history in dbo.nagios_hoststatus_HIST
	  --=============================================================================================================
      INSERT INTO LND_NAGIOS.Nagios_HostStatus_Hist (hoststatus_id, instance_id, host_object_id, status_update_time, output, long_output, perfdata, current_state, has_been_checked, should_be_scheduled, current_check_attempt, max_check_attempts, last_check, next_check, check_type, last_state_change, last_hard_state_change, last_hard_state, last_time_up, last_time_down, last_time_unreachable, state_type, last_notification, next_notification, no_more_notifications, notifications_enabled, problem_has_been_acknowledged, acknowledgement_type, current_notification_number, passive_checks_enabled, active_checks_enabled, event_handler_enabled, flap_detection_enabled, is_flapping, percent_state_change, latency, execution_time, scheduled_downtime_depth, failure_prediction_enabled, process_performance_data, obsess_over_host, modified_host_attributes, event_handler, check_command, normal_check_interval, retry_check_interval, check_timeperiod_object_id, lnd_updatedate)
        SELECT
            hs.hoststatus_id,
            hs.instance_id,
            hs.host_object_id,
            hs.status_update_time,
            hs.output,
            hs.long_output,
            hs.perfdata,
            hs.current_state,
            hs.has_been_checked,
            hs.should_be_scheduled,
            hs.current_check_attempt,
            hs.max_check_attempts,
            hs.last_check,
            hs.next_check,
            hs.check_type,
            hs.last_state_change,
            hs.last_hard_state_change,
            hs.last_hard_state,
            hs.last_time_up,
            hs.last_time_down,
            hs.last_time_unreachable,
            hs.state_type,
            hs.last_notification,
            hs.next_notification,
            hs.no_more_notifications,
            hs.notifications_enabled,
            hs.problem_has_been_acknowledged,
            hs.acknowledgement_type,
            hs.current_notification_number,
            hs.passive_checks_enabled,
            hs.active_checks_enabled,
            hs.event_handler_enabled,
            hs.flap_detection_enabled,
            hs.is_flapping,
            hs.percent_state_change,
            hs.latency,
            hs.execution_time,
            hs.scheduled_downtime_depth,
            hs.failure_prediction_enabled,
            hs.process_performance_data,
            hs.obsess_over_host,
            hs.modified_host_attributes,
            hs.event_handler,
            hs.check_command,
            hs.normal_check_interval,
            hs.retry_check_interval,
            hs.check_timeperiod_object_id,
            hs.lnd_updatedate
          FROM
            LND_NAGIOS_STAGE_CDC.Nagios_HostStatus AS hs
          WHERE (hs.current_check_attempt = hs.max_check_attempts
           OR hs.current_state = 0)
           AND NOT EXISTS (
            SELECT
                1
              FROM
                LND_NAGIOS.Nagios_HostStatus_Hist AS hist
              WHERE hist.host_object_id = hs.host_object_id
               AND hist.status_update_time = hs.status_update_time
          )
      ;
      SET log_message = 'Loaded LND_NAGIOS.Nagios_HostStatus_Hist from CDC Stage Table';
      CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, log_message, 'I', -1, NULL);
      CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, 'Completed load', 'I', -1, NULL);
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT concat('Error in Host_State_SRC_Load: ', @@error.message);
        CALL LND_NAGIOS_SUPPORT.ToLog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        RAISE USING MESSAGE = error_message; -- Rethrow the error!
      END;
    END;

/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC dbo.Host_Event_Load_After_CDC
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
SELECT TOP 1000 * FROM dbo.Host_Event
SELECT TOP 1000 * FROM dbo.nagios_hoststatus_HIST

--:: Data profile 
SELECT COUNT_BIG(1) nagios_hoststatus_STAGE FROM dbo.nagios_hoststatus_STAGE
SELECT COUNT_BIG(1) Host_Event FROM dbo.Host_Event
SELECT COUNT_BIG(1) nagios_hoststatus_HIST FROM dbo.nagios_hoststatus_HIST

SELECT 'dbo.nagios_hoststatus_STAGE' TableName, CONVERT(DATE, status_update_time) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Host_Object_ID) Dist_Count FROM LND_NAGIOS.dbo.nagios_hoststatus_STAGE GROUP BY CONVERT(DATE, status_update_time) ORDER BY Event_Date desc
SELECT 'dbo.Host_Event' TableName, CONVERT(DATE, Event_Date) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Host_Object_ID) Dist_Count FROM LND_NAGIOS.dbo.Host_Event GROUP BY CONVERT(DATE, Event_Date) ORDER BY Event_Date desc
SELECT 'dbo.nagios_hoststatus_HIST' TableName, CONVERT(DATE, status_update_time) Event_Date, COUNT_BIG(1) Row_Count, COUNT(DISTINCT Host_Object_ID) Dist_Count FROM LND_NAGIOS.dbo.nagios_hoststatus_HIST GROUP BY CONVERT(DATE, status_update_time) ORDER BY Event_Date desc

--TRUNCATE TABLE dbo.nagios_hoststatus_STAGE
--TRUNCATE TABLE dbo.Host_Event
--TRUNCATE TABLE dbo.nagios_hoststatus_HIST
--TRUNCATE TABLE Utility.ProcessLog
*/

  END;