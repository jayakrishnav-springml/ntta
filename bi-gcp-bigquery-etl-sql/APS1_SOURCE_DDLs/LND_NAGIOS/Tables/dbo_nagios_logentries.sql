CREATE TABLE [dbo].[nagios_logentries]
(
	[logentry_id] int NULL,
	[instance_id] int NULL,
	[logentry_time] datetime NULL,
	[entry_time] datetime NULL,
	[entry_time_usec] int NULL,
	[logentry_type] int NULL,
	[logentry_data] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[realtime_data] smallint NULL,
	[inferred_data_extracted] smallint NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([logentry_id]))
