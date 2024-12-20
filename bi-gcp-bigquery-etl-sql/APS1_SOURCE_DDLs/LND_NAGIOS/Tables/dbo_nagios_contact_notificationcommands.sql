CREATE TABLE [dbo].[nagios_contact_notificationcommands]
(
	[contact_notificationcommand_id] int NULL,
	[instance_id] smallint NULL,
	[contact_id] int NULL,
	[notification_type] smallint NULL,
	[command_object_id] int NULL,
	[command_args] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([contact_notificationcommand_id]))
