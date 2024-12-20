CREATE TABLE [dbo].[nagios_downtimehistory]
(
	[downtimehistory_id] int NULL,
	[instance_id] smallint NULL,
	[downtime_type] smallint NULL,
	[object_id] int NULL,
	[entry_time] datetime NULL,
	[author_name] nvarchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[comment_data] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[internal_downtime_id] int NULL,
	[triggered_by_id] int NULL,
	[is_fixed] smallint NULL,
	[duration] smallint NULL,
	[scheduled_start_time] datetime NULL,
	[scheduled_end_time] datetime NULL,
	[was_started] smallint NULL,
	[actual_start_time] datetime NULL,
	[actual_start_time_usec] int NULL,
	[actual_end_time] datetime NULL,
	[actual_end_time_usec] int NULL,
	[was_cancelled] smallint NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([downtimehistory_id]))
