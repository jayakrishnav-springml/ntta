CREATE TABLE [dbo].[nagios_servicestatus_STAGE]
(
	[servicestatus_id] int NULL,
	[instance_id] smallint NULL,
	[service_object_id] int NULL,
	[status_update_time] datetime NULL,
	[output] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[long_output] varchar(8000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[perfdata] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[current_state] smallint NULL,
	[has_been_checked] smallint NULL,
	[should_be_scheduled] smallint NULL,
	[current_check_attempt] smallint NULL,
	[max_check_attempts] smallint NULL,
	[last_check] datetime NULL,
	[next_check] datetime NULL,
	[check_type] smallint NULL,
	[last_state_change] datetime NULL,
	[last_hard_state_change] datetime NULL,
	[last_hard_state] smallint NULL,
	[last_time_ok] datetime NULL,
	[last_time_warning] datetime NULL,
	[last_time_unknown] datetime NULL,
	[last_time_critical] datetime NULL,
	[state_type] smallint NULL,
	[last_notification] datetime NULL,
	[next_notification] datetime NULL,
	[no_more_notifications] smallint NULL,
	[notifications_enabled] smallint NULL,
	[problem_has_been_acknowledged] smallint NULL,
	[acknowledgement_type] smallint NULL,
	[current_notification_number] smallint NULL,
	[passive_checks_enabled] smallint NULL,
	[active_checks_enabled] smallint NULL,
	[event_handler_enabled] smallint NULL,
	[flap_detection_enabled] smallint NULL,
	[is_flapping] smallint NULL,
	[percent_state_change] float(53) NULL,
	[latency] float(53) NULL,
	[execution_time] float(53) NULL,
	[scheduled_downtime_depth] smallint NULL,
	[failure_prediction_enabled] smallint NULL,
	[process_performance_data] smallint NULL,
	[obsess_over_service] smallint NULL,
	[modified_service_attributes] int NULL,
	[event_handler] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[check_command] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[normal_check_interval] float(53) NULL,
	[retry_check_interval] float(53) NULL,
	[check_timeperiod_object_id] int NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(HEAP, DISTRIBUTION = HASH([servicestatus_id]))
