CREATE TABLE [dbo].[nagios_servicechecks]
(
	[instance_id] smallint NULL,
	[service_object_id] int NULL,
	[check_type] smallint NULL,
	[current_check_attempt] smallint NULL,
	[max_check_attempts] smallint NULL,
	[state] smallint NULL,
	[state_type] smallint NULL,
	[start_time] datetime NULL,
	[start_time_usec] int NULL,
	[end_time] datetime NULL,
	[end_time_usec] int NULL,
	[command_object_id] int NULL,
	[command_args] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[command_line] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[timeout] smallint NULL,
	[early_timeout] smallint NULL,
	[execution_time] float(53) NULL,
	[latency] float(53) NULL,
	[return_code] smallint NULL,
	[output] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[long_output] nvarchar(4000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[perfdata] nvarchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[servicecheck_id] nvarchar(25) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = REPLICATE)
