CREATE TABLE [dbo].[nagios_commands_hist]
(
	[command_id] int NULL,
	[instance_id] smallint NULL,
	[config_type] smallint NULL,
	[object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([command_id]))
