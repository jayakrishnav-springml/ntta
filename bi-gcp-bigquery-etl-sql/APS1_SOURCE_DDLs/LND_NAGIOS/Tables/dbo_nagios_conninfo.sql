CREATE TABLE [dbo].[nagios_conninfo]
(
	[conninfo_id] int NULL,
	[instance_id] smallint NULL,
	[agent_name] nvarchar(32) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[agent_version] nvarchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[disposition] nvarchar(16) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[connect_source] nvarchar(16) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[connect_type] nvarchar(16) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[connect_time] datetime NULL,
	[disconnect_time] datetime NULL,
	[last_checkin_time] datetime NULL,
	[data_start_time] datetime NULL,
	[data_end_time] datetime NULL,
	[bytes_processed] int NULL,
	[lines_processed] int NULL,
	[entries_processed] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([conninfo_id]))
