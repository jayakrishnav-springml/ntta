CREATE PROC [dbo].[Service_Event_Load_After_CDC] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Landing data transfer after SSIS. Load dbo.Nagios_Service_Event from CDC STAGE data. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHGXXXXXX	Shankar		2021-03-26	New!
CHG0041826	Shankar		2022-10-27	Ouput column can have max 200 char. Issue fix.
===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Service_Event_Load_After_CDC 

SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Service_Event_Load_After_CDC', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started load', 'I', NULL, NULL

		DROP STATISTICS dbo.nagios_servicestatus_STAGE.STATS_dbo_nagios_servicestatus_STAGE_01
		DROP STATISTICS dbo.nagios_servicestatus_STAGE.STATS_dbo_nagios_servicestatus_STAGE_02

		CREATE STATISTICS STATS_dbo_nagios_servicestatus_STAGE_01 ON dbo.nagios_servicestatus_STAGE (service_Object_ID)
		CREATE STATISTICS STATS_dbo_nagios_servicestatus_STAGE_02 ON dbo.nagios_servicestatus_STAGE (status_update_time)
		
		SET  @Log_Message = 'Dropped and created STATISTICS for dbo.nagios_servicestatus_STAGE' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--=============================================================================================================
		-- Load dbo.Service_Event. This is the main input table for EDW Load.
		--=============================================================================================================
		INSERT	dbo.Service_Event (Service_Event_ID, Service_Object_ID, Event_Date, Service_State, Host, Service, Event_Info, Perf_Data, Metric_String, Metric_Count, LND_UpdateDate)		
		SELECT	
				CONVERT(BIGINT,RIGHT(CONVERT(VARCHAR(8), status_update_time,112),6) + REPLACE(CONVERT (VARCHAR(8),status_update_time, 108),':','')  + RIGHT('00000'+CONVERT(VARCHAR,ss.service_object_id),6)) Service_Event_ID
				,ss.Service_Object_ID
				,status_update_time AS Event_Date
 				,ss.Current_State AS Service_State
				,ho.name1 Host
				,s.display_name AS [Service]
				,LEFT(ss.output,200) AS Event_Info
				,NULLIF(RTRIM(ss.perfdata),'') AS Perf_Data
				,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(
						CASE WHEN RTRIM(ss.perfdata) LIKE '%\n' THEN STUFF(NULLIF(RTRIM(ss.perfdata),'\n'), LEN(RTRIM(ss.perfdata))-1, 2, ';')
							 WHEN RIGHT(NULLIF(RTRIM(ss.perfdata),''),1) <> ';' THEN RTRIM(ss.perfdata) + ';'
							 ELSE NULLIF(RTRIM(ss.perfdata),'')
						END
						),'''',''),'; ',';'),':','_'),' pl=',';pl='),' hostgroup_collectors',';hostgroup_collectors'),' size=',';size='),' ','_'),'-','_'),'=_','=-') AS Metric_String
				,LEN(ss.perfdata) - LEN(replace(ss.perfdata,'=','')) AS Metric_Count
				,ss.LND_UpdateDate
		FROM	dbo.nagios_ServiceStatus_STAGE ss  
		JOIN	dbo.nagios_services s  
					ON ss.service_object_id = s.service_object_id   
		JOIN	dbo.nagios_objects ho
					ON s.host_object_id = ho.object_id
		WHERE	(ss.current_check_attempt = ss.max_check_attempts OR ss.current_state = 0)  
				AND NOT EXISTS (SELECT 1 FROM dbo.Service_Event f WHERE f.Service_Object_ID = ss.service_object_id AND f.Event_Date = ss.status_update_time)
		OPTION (LABEL = 'LND_NAGIOS.dbo.Service_Event Load');
		
		SET  @Log_Message = 'Loaded dbo.Service_Event from CDC Stage Table' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		UPDATE STATISTICS dbo.Service_Event
		
		SET  @Log_Message = 'Updated STATISTICS for dbo.Service_Event' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--=============================================================================================================
		-- Archive history in dbo.nagios_ServiceStatus_HIST
		--=============================================================================================================
		INSERT  dbo.nagios_servicestatus_HIST (servicestatus_id, instance_id, service_object_id, status_update_time, output, long_output, perfdata, current_state, has_been_checked, should_be_scheduled, current_check_attempt, max_check_attempts, last_check, next_check, check_type, last_state_change, last_hard_state_change, last_hard_state, last_time_ok, last_time_warning, last_time_unknown, last_time_critical, state_type, last_notification, next_notification, no_more_notifications, notifications_enabled, problem_has_been_acknowledged, acknowledgement_type, current_notification_number, passive_checks_enabled, active_checks_enabled, event_handler_enabled, flap_detection_enabled, is_flapping, percent_state_change, latency, execution_time, scheduled_downtime_depth, failure_prediction_enabled, process_performance_data, obsess_over_service, modified_service_attributes, event_handler, check_command, normal_check_interval, retry_check_interval, check_timeperiod_object_id, LND_UpdateDate)
		SELECT	servicestatus_id, instance_id, service_object_id, status_update_time, output, long_output, perfdata, current_state, has_been_checked, should_be_scheduled, current_check_attempt, max_check_attempts, last_check, next_check, check_type, last_state_change, last_hard_state_change, last_hard_state, last_time_ok, last_time_warning, last_time_unknown, last_time_critical, state_type, last_notification, next_notification, no_more_notifications, notifications_enabled, problem_has_been_acknowledged, acknowledgement_type, current_notification_number, passive_checks_enabled, active_checks_enabled, event_handler_enabled, flap_detection_enabled, is_flapping, percent_state_change, latency, execution_time, scheduled_downtime_depth, failure_prediction_enabled, process_performance_data, obsess_over_service, modified_service_attributes, event_handler, check_command, normal_check_interval, retry_check_interval, check_timeperiod_object_id, LND_UpdateDate
		FROM	dbo.nagios_servicestatus_STAGE ss
		WHERE	(ss.current_check_attempt = ss.max_check_attempts OR ss.current_state = 0)
				AND NOT EXISTS (SELECT 1 FROM dbo.nagios_servicestatus_HIST ssh WHERE ssh.service_object_id = ss.service_object_id AND ssh.status_update_time = ss.status_update_time)
		OPTION (LABEL = 'LND_NAGIOS.dbo.nagios_servicestatus_HIST Load');
		
		SET  @Log_Message = 'Loaded dbo.nagios_servicestatus_HIST from CDC Stage Table' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		UPDATE STATISTICS dbo.nagios_ServiceStatus_HIST

		SET  @Log_Message = 'Updated STATISTICS for dbo.nagios_servicestatus_HIST' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL
	
		
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed load', 'I', -1, NULL
	END	TRY
	
	BEGIN CATCH
		
		DECLARE @Error_Message VARCHAR(MAX) = 'Error in Service_Event_Load: ' + ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		THROW;  -- Rethrow the error!
	
	END CATCH

END

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
 
