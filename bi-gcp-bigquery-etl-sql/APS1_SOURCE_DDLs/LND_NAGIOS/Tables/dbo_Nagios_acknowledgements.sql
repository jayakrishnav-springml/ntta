CREATE TABLE [dbo].[Nagios_acknowledgements]
(
	[acknowledgement_id] int NULL,
	[instance_id] smallint NULL,
	[entry_time] datetime NULL,
	[entry_time_usec] int NULL,
	[acknowledgement_type] smallint NULL,
	[object_id] int NULL,
	[state] smallint NULL,
	[author_name] nvarchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[comment_data] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[is_sticky] smallint NULL,
	[persistent_comment] smallint NULL,
	[notify_contacts] smallint NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([acknowledgement_id]))
