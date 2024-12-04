CREATE TABLE [dbo].[nagios_systemcommands]
(
	[systemcommand_id] int NULL,
	[instance_id] smallint NULL,
	[start_time] datetime NULL,
	[start_time_usec] int NULL,
	[end_time] datetime NULL,
	[end_time_usec] int NULL,
	[command_line] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[timeout] smallint NULL,
	[early_timeout] smallint NULL,
	[execution_time] float(53) NULL,
	[return_code] smallint NULL,
	[output] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[long_output] nvarchar(max) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([systemcommand_id]))
