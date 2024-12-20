CREATE PROC [dbo].[Host_Event_Load_After_CDC] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Landing data transfer after SSIS. Load dbo.Nagios_Host_Event from CDC STAGE data. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHGXXXXXX	Shankar		2021-03-26	New!
CHG0041826	Shankar		2022-10-27	Ouput column can have max 200 char. 

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC dbo.Host_Event_Load_After_CDC
SELECT * FROM Utility.ProcessLog ORDER BY 1 DESC
SELECT TOP 1000 * FROM dbo.Host_Event
SELECT TOP 1000 * FROM dbo.nagios_hoststatus_HIST
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'dbo.Host_Event_Load_After_CDC', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started load', 'I', NULL, NULL

		DROP STATISTICS dbo.nagios_hoststatus_STAGE.STATS_dbo_nagios_hoststatus_STAGE_01
		DROP STATISTICS dbo.nagios_hoststatus_STAGE.STATS_dbo_nagios_hoststatus_STAGE_02

		CREATE STATISTICS STATS_dbo_nagios_hoststatus_STAGE_01 ON dbo.nagios_hoststatus_STAGE (Host_Object_ID)
		CREATE STATISTICS STATS_dbo_nagios_hoststatus_STAGE_02 ON dbo.nagios_hoststatus_STAGE (status_update_time)

		SET  @Log_Message = 'Dropped and created STATISTICS for dbo.nagios_hoststatus_STAGE' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--=============================================================================================================
		-- Load dbo.Host_Event. This is the main input table for EDW Load.
		--=============================================================================================================
		INSERT	dbo.Host_Event (Host_Event_ID, Host_Object_ID, Event_Date, Host_State, Host, Event_Info, Perf_Data, Metric_String, Metric_Count, LND_UpdateDate)		
		SELECT	
				CONVERT(BIGINT,RIGHT(CONVERT(VARCHAR(8), status_update_time,112),6) + REPLACE(CONVERT (VARCHAR(8),status_update_time, 108),':','')  + RIGHT('00000'+CONVERT(VARCHAR,host_object_id),6)) Host_Event_ID
				,hs.Host_Object_ID
				,status_update_time AS Event_Date
 				,hs.Current_State AS Host_State
				,ho.name1 Host
				,LEFT(hs.output,200) AS Event_Info
				,NULLIF(RTRIM(hs.perfdata),'') AS Perf_Data
				,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(
						CASE WHEN RTRIM(hs.perfdata) LIKE '%\n' THEN STUFF(NULLIF(RTRIM(hs.perfdata),'\n'), LEN(RTRIM(hs.perfdata))-1, 2, ';')
							 WHEN RIGHT(NULLIF(RTRIM(hs.perfdata),''),1) <> ';' THEN RTRIM(hs.perfdata) + ';'
							 ELSE NULLIF(RTRIM(hs.perfdata),'')
						END
						),'''',''),'; ',';'),':','_'),' pl=',';pl='),' size=',';size='),'-','_'),'=_','=-'),' ','_'),'_rtmax=',';rtmax=') AS Metric_String
				,LEN(hs.perfdata) - LEN(replace(hs.perfdata,'=','')) AS Metric_Count
				,hs.LND_UpdateDate
		FROM	dbo.nagios_hoststatus_STAGE hs  
		JOIN	dbo.nagios_objects ho 
				ON hs.host_object_id = ho.object_id
		WHERE	(hs.current_check_attempt = hs.max_check_attempts OR hs.current_state = 0)
				AND NOT EXISTS (SELECT 1 FROM dbo.Host_Event src WHERE src.Host_Object_ID = hs.host_object_id AND src.Event_Date = hs.status_update_time)
		OPTION (LABEL = 'Nagios - dbo.Host_Event Load');
		
		SET  @Log_Message = 'Loaded dbo.Host_Event from CDC Stage Table' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		UPDATE STATISTICS dbo.Host_Event

		SET  @Log_Message = 'Updated STATISTICS for dbo.Host_Event' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--=============================================================================================================
		-- Archive history in dbo.nagios_hoststatus_HIST
		--=============================================================================================================
		INSERT  dbo.nagios_hoststatus_HIST (hoststatus_id,instance_id,host_object_id,status_update_time,output, long_output, perfdata,current_state,has_been_checked,should_be_scheduled,current_check_attempt,max_check_attempts,last_check,next_check,check_type,last_state_change,last_hard_state_change,last_hard_state,last_time_up,last_time_down,last_time_unreachable,state_type,last_notification,next_notification,no_more_notifications,notifications_enabled,problem_has_been_acknowledged,acknowledgement_type,current_notification_number,passive_checks_enabled,active_checks_enabled,event_handler_enabled,flap_detection_enabled,is_flapping,percent_state_change,latency,execution_time,scheduled_downtime_depth,failure_prediction_enabled,process_performance_data,obsess_over_host,modified_host_attributes,event_handler,check_command,normal_check_interval,retry_check_interval,check_timeperiod_object_id,LND_UpdateDate)
		SELECT	hoststatus_id,instance_id,host_object_id,status_update_time,output, long_output, perfdata,current_state,has_been_checked,should_be_scheduled,current_check_attempt,max_check_attempts,last_check,next_check,check_type,last_state_change,last_hard_state_change,last_hard_state,last_time_up,last_time_down,last_time_unreachable,state_type,last_notification,next_notification,no_more_notifications,notifications_enabled,problem_has_been_acknowledged,acknowledgement_type,current_notification_number,passive_checks_enabled,active_checks_enabled,event_handler_enabled,flap_detection_enabled,is_flapping,percent_state_change,latency,execution_time,scheduled_downtime_depth,failure_prediction_enabled,process_performance_data,obsess_over_host,modified_host_attributes,event_handler,check_command,normal_check_interval,retry_check_interval,check_timeperiod_object_id,LND_UpdateDate
		FROM	dbo.nagios_hoststatus_STAGE hs
		WHERE	(hs.current_check_attempt = hs.max_check_attempts OR hs.current_state = 0)
				AND NOT EXISTS (SELECT 1 FROM dbo.nagios_hoststatus_HIST hist WHERE hist.Host_Object_ID = hs.Host_object_id AND hist.status_update_time = hs.status_update_time)
		OPTION (LABEL = 'Nagios - dbo.nagios_hoststatus_HIST Load');
		
		SET  @Log_Message = 'Loaded dbo.nagios_hoststatus_HIST from CDC Stage Table' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		UPDATE STATISTICS dbo.nagios_hoststatus_HIST

		SET  @Log_Message = 'Updated STATISTICS for dbo.nagios_hoststatus_HIST' 
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed load', 'I', -1, NULL
		
	END	TRY
	
	BEGIN CATCH
		
		DECLARE @Error_Message VARCHAR(MAX) = 'Error in Host_State_SRC_Load: ' + ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		THROW;  -- Rethrow the error!
	
	END CATCH

END

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

