CREATE TABLE [dbo].[nagios_commands]
(
	[command_id] int NULL,
	[instance_id] smallint NULL,
	[config_type] smallint NULL,
	[object_id] int NULL,
	[command_line] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([command_id]))
