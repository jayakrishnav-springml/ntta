CREATE TABLE [dbo].[nagios_comments]
(
	[comment_id] int NULL,
	[instance_id] smallint NULL,
	[entry_time] datetime NULL,
	[entry_time_usec] int NULL,
	[comment_type] smallint NULL,
	[entry_type] smallint NULL,
	[object_id] int NULL,
	[comment_time] datetime NULL,
	[internal_comment_id] int NULL,
	[author_name] nvarchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[comment_data] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[is_persistent] smallint NULL,
	[comment_source] smallint NULL,
	[expires] smallint NULL,
	[expiration_time] datetime NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([comment_id]))
