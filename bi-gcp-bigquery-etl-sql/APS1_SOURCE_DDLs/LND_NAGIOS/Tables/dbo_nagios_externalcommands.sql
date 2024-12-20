CREATE TABLE [dbo].[nagios_externalcommands]
(
	[externalcommand_id] int NULL,
	[instance_id] smallint NULL,
	[entry_time] datetime NULL,
	[command_type] smallint NULL,
	[command_name] nvarchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[command_args] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([externalcommand_id]))
