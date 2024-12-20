CREATE TABLE [dbo].[nagios_processevents]
(
	[processevent_id] int NULL,
	[instance_id] smallint NULL,
	[event_type] smallint NULL,
	[event_time] datetime NULL,
	[event_time_usec] int NULL,
	[process_id] int NULL,
	[program_name] nvarchar(16) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[program_version] nvarchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[program_date] nvarchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([processevent_id]))
